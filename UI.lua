-- TreeNotes UI Module
TreeNotes.UI = {}

local currentNotebook = nil
local currentChapter = nil
local currentPage = nil

-- Main window creation
function TreeNotes:CreateMainWindow()
    local frame = CreateFrame("Frame", "TreeNotesMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("TreeNotes")

    -- Left panel (tree view)
    local treePanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    treePanel:SetSize(250, 520)
    treePanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)

    -- Tree scroll frame
    local treeScroll = CreateFrame("ScrollFrame", "TreeNotesTreeScroll", treePanel, "UIPanelScrollFrameTemplate")
    treeScroll:SetPoint("TOPLEFT", 5, -5)
    treeScroll:SetPoint("BOTTOMRIGHT", -25, 5)

    local treeContent = CreateFrame("Frame", nil, treeScroll)
    treeContent:SetSize(220, 500)
    treeScroll:SetScrollChild(treeContent)

    frame.treeContent = treeContent

    -- Right panel (content editor)
    local contentPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    contentPanel:SetSize(510, 520)
    contentPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -30)

    -- Title input
    local titleLabel = contentPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("TOPLEFT", contentPanel, "TOPLEFT", 10, -10)
    titleLabel:SetText("Title:")

    local titleInput = CreateFrame("EditBox", "TreeNotesTitleInput", contentPanel, "InputBoxTemplate")
    titleInput:SetSize(480, 30)
    titleInput:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 5, -5)
    titleInput:SetAutoFocus(false)
    titleInput:SetScript("OnTextChanged", function(self)
        TreeNotes:UpdateCurrentItemTitle(self:GetText())
    end)

    frame.titleInput = titleInput

    -- Content input (multiline)
    local contentScroll = CreateFrame("ScrollFrame", "TreeNotesContentScroll", contentPanel, "UIPanelScrollFrameTemplate")
    contentScroll:SetPoint("TOPLEFT", titleInput, "BOTTOMLEFT", -5, -10)
    contentScroll:SetPoint("BOTTOMRIGHT", contentPanel, "BOTTOMRIGHT", -25, 40)

    local contentEdit = CreateFrame("EditBox", "TreeNotesContentEdit", contentScroll)
    contentEdit:SetMultiLine(true)
    contentEdit:SetAutoFocus(false)
    contentEdit:SetFontObject("GameFontHighlight")
    contentEdit:SetWidth(470)
    contentEdit:SetScript("OnTextChanged", function(self)
        TreeNotes:UpdateCurrentPageContent(self:GetText())
    end)
    contentScroll:SetScrollChild(contentEdit)

    frame.contentEdit = contentEdit
    frame.contentScroll = contentScroll

    -- Raid symbol buttons
    local symbolPanel = CreateFrame("Frame", nil, contentPanel)
    symbolPanel:SetSize(490, 30)
    symbolPanel:SetPoint("BOTTOMLEFT", contentPanel, "BOTTOMLEFT", 10, 5)

    local symbolLabel = symbolPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    symbolLabel:SetPoint("LEFT", symbolPanel, "LEFT", 0, 0)
    symbolLabel:SetText("Symbols:")

    local symbols = {"skull", "cross", "square", "moon", "triangle", "diamond", "circle", "star"}
    local xOffset = 60

    for i, symbol in ipairs(symbols) do
        local btn = CreateFrame("Button", nil, symbolPanel, "UIPanelButtonTemplate")
        btn:SetSize(40, 25)
        btn:SetPoint("LEFT", symbolPanel, "LEFT", xOffset, 0)
        btn:SetText(strsub(symbol, 1, 1):upper())
        btn:SetScript("OnClick", function()
            TreeNotes:InsertSymbol(symbol)
        end)
        xOffset = xOffset + 45
    end

    frame.symbolPanel = symbolPanel

    -- Action buttons at the bottom of tree panel
    local addNotebookBtn = CreateFrame("Button", nil, treePanel, "UIPanelButtonTemplate")
    addNotebookBtn:SetSize(75, 25)
    addNotebookBtn:SetPoint("BOTTOMLEFT", treePanel, "BOTTOMLEFT", 5, 5)
    addNotebookBtn:SetText("+Notebook")
    addNotebookBtn:SetScript("OnClick", function()
        TreeNotes:AddNotebook()
    end)

    local addChapterBtn = CreateFrame("Button", nil, treePanel, "UIPanelButtonTemplate")
    addChapterBtn:SetSize(75, 25)
    addChapterBtn:SetPoint("LEFT", addNotebookBtn, "RIGHT", 5, 0)
    addChapterBtn:SetText("+Chapter")
    addChapterBtn:SetScript("OnClick", function()
        TreeNotes:AddChapter()
    end)

    local addPageBtn = CreateFrame("Button", nil, treePanel, "UIPanelButtonTemplate")
    addPageBtn:SetSize(75, 25)
    addPageBtn:SetPoint("LEFT", addChapterBtn, "RIGHT", 5, 0)
    addPageBtn:SetText("+Page")
    addPageBtn:SetScript("OnClick", function()
        TreeNotes:AddPage()
    end)

    self.mainFrame = frame
end

function TreeNotes:ToggleUI()
    if not self.mainFrame then
        self:CreateMainWindow()
    end

    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    else
        self:RefreshTree()
        self.mainFrame:Show()
    end
end

function TreeNotes:RefreshTree()
    if not self.mainFrame then return end

    -- Clear existing tree
    local treeContent = self.mainFrame.treeContent
    for _, child in ipairs({treeContent:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local yOffset = -5

    -- Build tree
    for _, notebook in ipairs(self.DB.notebooks) do
        local notebookBtn = self:CreateTreeButton(treeContent, notebook.title, 0, yOffset, "notebook", notebook.id)
        yOffset = yOffset - 25

        if notebook.expanded then
            for _, chapter in ipairs(notebook.chapters) do
                local chapterBtn = self:CreateTreeButton(treeContent, chapter.title, 15, yOffset, "chapter", notebook.id, chapter.id)
                yOffset = yOffset - 25

                if chapter.expanded then
                    for _, page in ipairs(chapter.pages) do
                        local pageBtn = self:CreateTreeButton(treeContent, page.title, 30, yOffset, "page", notebook.id, chapter.id, page.id)
                        yOffset = yOffset - 25
                    end
                end
            end
        end
    end

    treeContent:SetHeight(math.abs(yOffset) + 10)
end

function TreeNotes:CreateTreeButton(parent, text, indent, yOffset, itemType, notebookId, chapterId, pageId)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(220 - indent, 20)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", indent, yOffset)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("LEFT", btn, "LEFT", 5, 0)
    btn.text:SetText(text)
    btn.text:SetJustifyH("LEFT")

    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            TreeNotes:OnTreeItemClick(itemType, notebookId, chapterId, pageId)
        elseif button == "RightButton" then
            TreeNotes:ShowContextMenu(self, itemType, notebookId, chapterId, pageId)
        end
    end)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

    return btn
end

function TreeNotes:OnTreeItemClick(itemType, notebookId, chapterId, pageId)
    if itemType == "notebook" then
        local notebook = self:GetNotebook(notebookId)
        if notebook then
            notebook.expanded = not notebook.expanded
            currentNotebook = notebookId
            currentChapter = nil
            currentPage = nil
            self:RefreshTree()
            self:LoadNotebook(notebook)
        end
    elseif itemType == "chapter" then
        local chapter = self:GetChapter(notebookId, chapterId)
        if chapter then
            chapter.expanded = not chapter.expanded
            currentNotebook = notebookId
            currentChapter = chapterId
            currentPage = nil
            self:RefreshTree()
            self:LoadChapter(chapter)
        end
    elseif itemType == "page" then
        local page = self:GetPage(notebookId, chapterId, pageId)
        if page then
            currentNotebook = notebookId
            currentChapter = chapterId
            currentPage = pageId
            self:RefreshTree()
            self:LoadPage(page)
        end
    end
end

function TreeNotes:LoadNotebook(notebook)
    self.mainFrame.titleInput:SetText(notebook.title)
    self.mainFrame.contentEdit:SetText("")
    self.mainFrame.contentEdit:SetEnabled(false)
end

function TreeNotes:LoadChapter(chapter)
    self.mainFrame.titleInput:SetText(chapter.title)
    self.mainFrame.contentEdit:SetText("")
    self.mainFrame.contentEdit:SetEnabled(false)
end

function TreeNotes:LoadPage(page)
    self.mainFrame.titleInput:SetText(page.title)
    self.mainFrame.contentEdit:SetText(page.content or "")
    self.mainFrame.contentEdit:SetEnabled(true)
end

function TreeNotes:UpdateCurrentItemTitle(title)
    if currentPage then
        local page = self:GetPage(currentNotebook, currentChapter, currentPage)
        if page then
            page.title = title
            self:RefreshTree()
        end
    elseif currentChapter then
        local chapter = self:GetChapter(currentNotebook, currentChapter)
        if chapter then
            chapter.title = title
            self:RefreshTree()
        end
    elseif currentNotebook then
        local notebook = self:GetNotebook(currentNotebook)
        if notebook then
            notebook.title = title
            self:RefreshTree()
        end
    end
end

function TreeNotes:UpdateCurrentPageContent(content)
    if currentPage then
        local page = self:GetPage(currentNotebook, currentChapter, currentPage)
        if page then
            page.content = content
        end
    end
end

function TreeNotes:InsertSymbol(symbol)
    if currentPage and self.mainFrame.contentEdit:IsEnabled() then
        local text = self.mainFrame.contentEdit:GetText()
        local cursorPos = self.mainFrame.contentEdit:GetCursorPosition()
        local symbolText = TreeNotes.RaidSymbols[symbol]
        local newText = strsub(text, 1, cursorPos) .. symbolText .. strsub(text, cursorPos + 1)
        self.mainFrame.contentEdit:SetText(newText)
        self.mainFrame.contentEdit:SetCursorPosition(cursorPos + strlen(symbolText))
    end
end

function TreeNotes:AddNotebook()
    self:CreateNotebook("New Notebook")
    self:RefreshTree()
end

function TreeNotes:AddChapter()
    if not currentNotebook then
        print("Please select a notebook first!")
        return
    end
    self:CreateChapter(currentNotebook, "New Chapter")
    self:RefreshTree()
end

function TreeNotes:AddPage()
    if not currentChapter then
        print("Please select a chapter first!")
        return
    end
    self:CreatePage(currentNotebook, currentChapter, "New Page")
    self:RefreshTree()
end

function TreeNotes:ShowContextMenu(parent, itemType, notebookId, chapterId, pageId)
    local menu = CreateFrame("Frame", "TreeNotesContextMenu", UIParent, "UIDropDownMenuTemplate")

    local menuList = {
        {
            text = "Delete",
            func = function()
                if itemType == "notebook" then
                    TreeNotes:DeleteNotebook(notebookId)
                elseif itemType == "chapter" then
                    TreeNotes:DeleteChapter(notebookId, chapterId)
                elseif itemType == "page" then
                    TreeNotes:DeletePage(notebookId, chapterId, pageId)
                end
                TreeNotes:RefreshTree()
            end,
            notCheckable = true
        },
        {
            text = "Cancel",
            func = function() end,
            notCheckable = true
        }
    }

    EasyMenu(menuList, menu, "cursor", 0, 0, "MENU")
end
