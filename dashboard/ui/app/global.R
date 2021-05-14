rm(list = ls())
gc()

suppressMessages(library(shiny))
suppressMessages(library(dplyr))
suppressMessages(library(bs4Dash))
suppressMessages(library(reticulate))
suppressMessages(library(readbitmap))
suppressMessages(library(jpeg))
suppressMessages(library(png))

path_python_files = "python/api_funs.py"
reticulate::source_python(path_python_files)

docker = TRUE

MapExampleToImage = function(example_name){
  list = list("CA Logo (431x164)" = "ca_logo.png", 
              "Baboon (123x120)" = "baboon.png", 
              "Text (244x200)" = "text.png", 
              "Baby (128x128)" = "baby.png",
              "CD Player (351x292)" = "sony_cdplayer.jpg",
              "Sandals (350x124)" = "shoe.png") 
  
   if (is.null(example_name)){
     selected = NULL
   } else {
     selected = list[list == example_name][[1]]
   }
   
   return(list(selected = selected, all_selections = list))
}

# based on the Shiny fileInput function
fileInput2 <- function(inputId, label = NULL, labelIcon = NULL, multiple = FALSE, 
                       accept = NULL, width = NULL, progress = TRUE, ...) {
  # add class fileinput_2 defined in UI to hide the inputTag
  inputTag <- tags$input(id = inputId, name = inputId, type = "file", 
                         class = "fileinput_2")
  if (multiple) 
    inputTag$attribs$multiple <- "multiple"
  if (length(accept) > 0) 
    inputTag$attribs$accept <- paste(accept, collapse = ",")
  
  div(..., style = if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";"), 
      inputTag,
      # label customized with an action button
      tags$label(`for` = inputId, div(icon(labelIcon), label, 
                                      class = "btn btn-default action-button")),
      # optionally display a progress bar
      if(progress)
        tags$div(id = paste(inputId, "_progress", sep = ""), 
                 class = "progress shiny-file-input-progress", 
                 tags$div(class = "progress-bar")
        )
  )
}



js <- HTML('
$(document).on("shiny:sessioninitialized", function(event) {
   $(\'a[data-value="tab_tryit"]\').tab("show");
   
   
});
           
function moveDivisor() { 
  divisor.style.width = slider.value+"%";
}

')


jsCode <- "shinyjs.insertImage = function(params){
  var src_path_1 = params[0]
  var src_path_2 = params[1]
  var src_path_3 = params[2]
  var image_height = params[3]
  
  $('#myimage').attr('src', src_path_1);
  $('#myimage').attr('height', image_height);
  $('#myimage2').attr('src', src_path_2);
  $('#myimage2').attr('height', image_height);
  $('#myimage3').attr('src', src_path_3);
  $('#myimage3').attr('height', image_height);
}"

jsCode2 <- 
   '
shinyjs.imageZoom = function(params) {
  var imgID = params[0]; 
  var resultID = params[1];
  
  var img, lens, result, cx, cy;
  img = document.getElementById(imgID);
  result = document.getElementById(resultID);
  $("#" + resultID).attr("style", "");
   if (img.previousSibling.className === "img-zoom-lens") {
      img.previousSibling.remove();
  }
  /*create lens:*/
  lens = document.createElement("DIV");
  lens.setAttribute("class", "img-zoom-lens");
  /*insert lens:*/
  img.parentElement.insertBefore(lens, img);
  /*calculate the ratio between result DIV and lens:*/
  console.log(result);
  console.log(img);
  cx = result.offsetWidth / lens.offsetWidth;
  cy = result.offsetHeight / lens.offsetHeight;
  /*set background properties for the result DIV:*/
  result.style.backgroundImage = "url(\'" + img.src + "\')";
  result.style.backgroundSize = (img.width * cx) + "px " + (img.height * cy) + "px";
  console.log(img.width);
  console.log(img.height);
  /*execute a function when someone moves the cursor over the image, or the lens:*/
  lens.addEventListener("mousemove", moveLens);
  img.addEventListener("mousemove", moveLens);
  /*and also for touch screens:*/
  lens.addEventListener("touchmove", moveLens);
  img.addEventListener("touchmove", moveLens);
  function moveLens(e) {
    var pos, x, y;
    /*prevent any other actions that may occur when moving over the image:*/
    e.preventDefault();
    /*get the cursors x and y positions:*/
   pos = getCursorPos(e);
   /*calculate the position of the lens:*/
   x = pos.x - (lens.offsetWidth / 2);
   y = pos.y - (lens.offsetHeight / 2);
   /*prevent the lens from being positioned outside the image:*/
     if (x > img.width - lens.offsetWidth) {x = img.width - lens.offsetWidth}
   if (x < 0) {x = 0}
   if (y > img.height - lens.offsetHeight) {y = img.height - lens.offsetHeight}
   if (y < 0) {y = 0}
   /*set the position of the lens:*/
     lens.style.left = x + "px";
   lens.style.top = y + "px";
   /*display what the lens "sees":*/
     result.style.backgroundPosition = "-" + (x * cx) + "px -" + (y * cy) + "px";
   }
   function getCursorPos(e) {
     var a, x = 0, y = 0;
     e = e || window.event;
     /*get the x and y positions of the image:*/
       a = img.getBoundingClientRect();
       /*calculate the cursors x and y coordinates, relative to the image:*/
       x = e.pageX - a.left;
       y = e.pageY - a.top;
       /*consider any page scrolling:*/
       x = x - window.pageXOffset;
       y = y - window.pageYOffset;
       return {x : x, y : y};
     }
}
'