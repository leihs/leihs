class window.App.ModelsUploadController extends Spine.Controller

  elements:
    ".list-of-lines": "list"

  events:
    "click [data-type='select']": "click"
    "fileuploadadd": "add"
    "click [data-type='inline-entry'][data-new] [data-remove]": "remove"

  click: => @el.find("input[type='file']").trigger "click"

  constructor: ->
    super
    @uploadList = []
    @uploadErrors = []
    @el.fileupload
      fileInput: @fileInput
      autoUpload: false

  add: (e, uploadData)=> 
    @uploadList.push uploadData
    for file in uploadData.files
      @processNewFile @renderFile(file, uploadData), file

  processNewFile: (template, file)=> #virtual

  renderFile: (file, uploadData)=>
    template = $ App.Render @templatePath, file, {uid: App.Model.uid("uid")}
    template.data "uploadData", uploadData
    @list.prepend template
    template

  setupPreviewImage: (entry, file)=>
    reader = new FileReader()
    reader.onload = (e)=> entry.find("img").attr "src", e.target.result
    reader.readAsDataURL file

  upload: (callback)=>
    unless @uploadList.length
      do callback  
      return
    do @showUploading
    @el.data("blueimpFileupload").options.url = @model.url("upload/#{@type}")
    always = _.after @uploadList.length, => do callback
    fail = (e)=> @uploadErrors.push(e.responseText)
    for upload in @uploadList
      upload.submit().fail(fail).always(always)

  showUploading: => 
    modal = new App.Modal $ "<div></div>"
    modal.undestroyable()
    App.Flash
      type: "notice"
      message: _jed "Uploading files - please wait"
      loading: true
    , 9999

  remove: (e)=>
    entry = $(e.currentTarget).closest("[data-type='inline-entry']")
    @uploadList = _.filter @uploadList, (e) -> e != entry.data("uploadData")