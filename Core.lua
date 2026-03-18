-- TreeNotes Core Module
TreeNotes = {}
TreeNotes.DB = {}

-- Raid symbols mapping
TreeNotes.RaidSymbols = {
    ["skull"] = "{skull}",
    ["cross"] = "{cross}",
    ["square"] = "{square}",
    ["moon"] = "{moon}",
    ["triangle"] = "{triangle}",
    ["diamond"] = "{diamond}",
    ["circle"] = "{circle}",
    ["star"] = "{star}"
}

-- Initialize the addon
function TreeNotes:Initialize()
    if not TreeNotesDB then
        TreeNotesDB = {
            notebooks = {}
        }
    end
    self.DB = TreeNotesDB

    print("TreeNotes loaded! Type /treenotes to open.")
end

-- Data structure functions
function TreeNotes:CreateNotebook(title)
    local notebook = {
        id = self:GenerateID(),
        title = title or "New Notebook",
        chapters = {}
    }
    table.insert(self.DB.notebooks, notebook)
    return notebook
end

function TreeNotes:CreateChapter(notebookId, title)
    local notebook = self:GetNotebook(notebookId)
    if not notebook then return nil end

    local chapter = {
        id = self:GenerateID(),
        title = title or "New Chapter",
        pages = {}
    }
    table.insert(notebook.chapters, chapter)
    return chapter
end

function TreeNotes:CreatePage(notebookId, chapterId, title)
    local chapter = self:GetChapter(notebookId, chapterId)
    if not chapter then return nil end

    local page = {
        id = self:GenerateID(),
        title = title or "New Page",
        content = ""
    }
    table.insert(chapter.pages, page)
    return page
end

function TreeNotes:GetNotebook(notebookId)
    for _, notebook in ipairs(self.DB.notebooks) do
        if notebook.id == notebookId then
            return notebook
        end
    end
    return nil
end

function TreeNotes:GetChapter(notebookId, chapterId)
    local notebook = self:GetNotebook(notebookId)
    if not notebook then return nil end

    for _, chapter in ipairs(notebook.chapters) do
        if chapter.id == chapterId then
            return chapter
        end
    end
    return nil
end

function TreeNotes:GetPage(notebookId, chapterId, pageId)
    local chapter = self:GetChapter(notebookId, chapterId)
    if not chapter then return nil end

    for _, page in ipairs(chapter.pages) do
        if page.id == pageId then
            return page
        end
    end
    return nil
end

function TreeNotes:DeleteNotebook(notebookId)
    for i, notebook in ipairs(self.DB.notebooks) do
        if notebook.id == notebookId then
            table.remove(self.DB.notebooks, i)
            return true
        end
    end
    return false
end

function TreeNotes:DeleteChapter(notebookId, chapterId)
    local notebook = self:GetNotebook(notebookId)
    if not notebook then return false end

    for i, chapter in ipairs(notebook.chapters) do
        if chapter.id == chapterId then
            table.remove(notebook.chapters, i)
            return true
        end
    end
    return false
end

function TreeNotes:DeletePage(notebookId, chapterId, pageId)
    local chapter = self:GetChapter(notebookId, chapterId)
    if not chapter then return false end

    for i, page in ipairs(chapter.pages) do
        if page.id == pageId then
            table.remove(chapter.pages, i)
            return true
        end
    end
    return false
end

function TreeNotes:GenerateID()
    return tostring(time()) .. tostring(math.random(1000, 9999))
end

-- Slash command handler
SLASH_TREENOTES1 = "/treenotes"
SlashCmdList["TREENOTES"] = function(msg)
    TreeNotes:ToggleUI()
end

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "TreeNotes" then
        TreeNotes:Initialize()
    end
end)
