$(document).ready(function() {
  setupEditor();
  setupWysiwygEditor();
  $(".markdown code").addClass("prettyprint");
});

function setupWysiwygEditor() {
  var editor = $("#wysiwyg_editor");
  if(!editor || editor.length == 0)
    return;
// events: {
//   click: function(e) {
//     if(!window.onbeforeunload && !hasStorage()) {
//       //I18n.on_leave_page
//       window.onbeforeunload = function() {return I18n.on_leave_page;};
//     }
//   }
// }
  editor.htmlarea({
    toolbar: [
      ["html"], ["bold", "italic", "underline", "strikethrough", "|", "subscript", "superscript"],
      ["increasefontsize", "decreasefontsize"],
      ["orderedlist", "unorderedlist"],
      ["indent", "outdent"],
      ["justifyleft", "justifycenter", "justifyright"],
      ["link", "unlink", "image", "horizontalrule"],
      ["p", "h1", "h2", "h3", "h4", "h5", "h6"],
      ["cut", "copy", "paste"],
      [{
          css: "removeformat",
          text: "Remove Format",
          action: function(btn) {
            this.removeFormat();
          }
      }]
    ]
  });
}

function setupEditor() {
  var editor = $("#markdown_editor");
  if(!editor || editor.length == 0)
    return;

  var converter = new Showdown.converter;
  var timer_id = null;

  var converter_callback = function(value) {
    $('#markdown_preview')[0].innerHTML = converter.makeHtml(value);
    //addToLocalStorage(location.href, 'markdown_editor', value);
    $('#markdown_preview.markdown p code').addClass("prettyprint");
    if(timer_id)
      clearTimeout(timer_id);

    timer_id = setTimeout(function(){
      prettyPrint();
    }, 500);

  }

  var textarea = editor.TextArea({
    change: converter_callback
  });

  var toolbar = $.Toolbar(textarea, {
    className: "markdown_toolbar"
  });

  //buttons
  toolbar.addButton('Kursywa',function(){
      this.wrapSelection('*','*');
  },{
    id: 'markdown_italics_button'
  });

  toolbar.addButton('Pogrubienie',function(){
      this.wrapSelection('**','**');
  },{
    id: 'markdown_bold_button'
  });

  toolbar.addButton('Link',function(){
    var selection = this.getSelection();
    var response = prompt('Podaj adres URL','');
    if(response == null)
        return;
    this.replaceSelection('[' + (selection == '' ? 'Link Text' : selection) + '](' + (response == '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://') + ')');
  },{
    id: 'markdown_link_button'
  });

  toolbar.addButton('Obraz',function(){
    var selection = this.getSelection();
    var response = prompt('Podaj adres URL','');
    if(response == null)
        return;
    this.replaceSelection('![' + (selection == '' ? 'Image Alt Text' : selection) + '](' + (response == '' ? 'http://image_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://') + ')');
  },{
    id: 'markdown_image_button'
  });

  toolbar.addButton('Nagłówek',function(){
    var selection = this.getSelection();
    if(selection == '')
        selection = 'Nagłówek';
    this.replaceSelection('##'+selection+'##');
  },{
    id: 'markdown_heading_button'
  });

  toolbar.addButton('Lista nieuporządkowana',function(event){
    this.collectFromEachSelectedLine(function(line){
        return event.shiftKey ? (line.match(/^\*{2,}/) ? line.replace(/^\*/,'') : line.replace(/^\*\s/,'')) : (line.match(/\*+\s/) ? '*' : '* ') + line;
    });
  },{
    id: 'markdown_unordered_list_button'
  });

  toolbar.addButton('Lista numerowana',function(event){
    var i = 0;
    this.collectFromEachSelectedLine(function(line){
        if(!line.match(/^\s+$/)){
            ++i;
            return event.shiftKey ? line.replace(/^\d+\.\s/,'') : (line.match(/\d+\.\s/) ? '' : i + '. ') + line;
        }
    });
  },{
    id: 'markdown_ordered_list_button'
  });

  toolbar.addButton('Cytat',function(event){
    this.collectFromEachSelectedLine(function(line){
        return event.shiftKey ? line.replace(/^\> /,'') : '> ' + line;
    });
  },{
    id: 'markdown_quote_button'
  });

  toolbar.addButton('Kod',function(event){
    this.collectFromEachSelectedLine(function(line){
        return event.shiftKey ? line.replace(/    /,'') : '    ' + line;
    });
  },{
    id: 'markdown_code_button'
  });

/*
  toolbar.addButton('LaTeX', function(event) {
    this.wrapSelection('$$','$$');
  }, {
    id: 'markdown_latex_button'
  });
  */

  toolbar.addButton('Pomoc',function(){
    window.open('http://daringfireball.net/projects/markdown/dingus');
  },{
    id: 'markdown_help_button'
  });

}
