local md5 = require "md5"
local imgui = require "mimgui"
local memory = require "memory"
local Utils = require "utils"
imgui.ImageURL = {
    cache_dir = getGameDirectory() .. "/resource/cache",
    download_statuses = {
        INIT = 0,
        DOWNLOADING = 1,
        ERROR = 2,
        SAVED = 3,
        NOT_MODIFIED = 4,
        CACHE_ONLY = 5
    },
    pool = {}
}

function imgui.ImageURL:set_cache(url, image_data, headers)
    if not doesDirectoryExist(self.cache_dir) then
        createDirectory(self.cache_dir)
    end

    local path = ("%s/%s"):format(self.cache_dir, md5.sumhexa(url))
    local file, err = io.open(path, "wb")
    if not file then
        return nil
    end

    local data = { Data = tostring(image_data) }
    if headers["etag"] then
        data["Etag"] = headers["etag"]
    end
    if headers["last-modified"] then
        data["Last-Modified"] = headers["last-modified"]
    end

    file:write(encodeJson(data))
    file:close()
    return path
end

function imgui.ImageURL:get_cache(url)
    local path = ("%s/%s"):format(self.cache_dir, md5.sumhexa(url))
    if not doesFileExist(path) then
        return nil, nil
    end

    local image_data = nil
    local cached_headers = {}

    local file, err = io.open(path, "rb")
    if file then
        local cache = decodeJson(file:read("*a"))
        if type(cache) ~= "table" then
            return nil, nil
        end

        if cache["Data"] ~= nil then
               image_data = cache["Data"]
           end
           if cache["Last-Modified"] ~= nil then
               cached_headers["If-Modified-Since"] = cache["Last-Modified"]
           end
           if cache["Etag"] ~= nil then
               cached_headers["If-None-Match"] = cache["Etag"]
           end

        file:close()
    end
    return image_data, cached_headers
end

function imgui.ImageURL:download(url, preload_cache)
    local st = self.download_statuses
    self.pool[url] = {
        status = st.DOWNLOADING,
        image = nil,
        error = nil
    }
    local cached_image, cached_headers = imgui.ImageURL:get_cache(url)
    local img = self.pool[url]

    if preload_cache and cached_image ~= nil then
        img.image = imgui.CreateTextureFromFileInMemory(memory.strptr(cached_image), #cached_image)
    end
    Utils.asyncHttpRequest("GET", url, { headers = cached_headers },
        function(result)
            if result.status_code == 200 then
                img.image = imgui.CreateTextureFromFileInMemory(memory.strptr(result.text), #result.text)
                img.status = st.SAVED
                imgui.ImageURL:set_cache(url, result.text, result.headers)
            elseif result.status_code == 304 then
                img.image = img.image or imgui.CreateTextureFromMemory(memory.strptr(cached_image), #cached_image)
                img.status = st.NOT_MODIFIED
            else
                img.status = img.image and st.CACHE_ONLY or st.ERROR
                img.error = ("Error #%s"):format(result.status_code)
            end
        end,
        function(error)
            img.status = img.image and st.CACHE_ONLY or st.ERROR
            img.error = error
        end
    )
end

function imgui.ImageURL:render(url, size, preload, ...)
    local st = self.download_statuses
    local img = self.pool[url]

    if img == nil then
        self.pool[url] = {
            status = st.INIT,
            error = nil,
            image = nil
        }
        img = self.pool[url]
    end

    if img.status == st.INIT then
        imgui.ImageURL:download(url, preload)
    end
        
    if img.image ~= nil then
        imgui.Image(img.image, size, ...)
    else
        imgui.Dummy(size)
    end
    return img.status, img.error
end

function imgui.ImageURL:getImage(url, preload)
    local st = self.download_statuses
    local img = self.pool[url]

    if img == nil then
        self.pool[url] = {
            status = st.INIT,
            error = nil,
            image = nil
        }
        img = self.pool[url]
    end

    if img.status == st.INIT then
        imgui.ImageURL:download(url, preload)
    end

    return img.image, img.status, img.error
end

return setmetatable(imgui.ImageURL, {
    __call = imgui.ImageURL.getImage
})