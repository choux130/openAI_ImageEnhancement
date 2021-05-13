shinyServer(function(input, output, session) {
    values = reactiveValues(
        previous_custom_file_name = NULL,
        folder_path = NULL,
        status_code = NULL, 
        image_finish_trigger = NULL
    )
    
    observe({
        if (input$radio_input_selection == "example"){
            values$status_code = 200
        } else {
          if (is.null(input$myFile)){
              values$status_code = NULL
          }  
        }
    })
    
    observe({
        if (input$radio_input_selection == "example"){
            values$folder_path = "output_example"
            values$status_code = 200
        } else {
            values$folder_path = "output"
        }
    })

    observe({
        if (input$radio_input_selection != "example" & is.null(input$myFile)){
            shinyjs::hide(id = "zoom_1")
            shinyjs::hide(id = "zoom_2")
            shinyjs::hide(id = "zoom_3")
        } else {
            shinyjs::show(id = "zoom_1")
            shinyjs::show(id = "zoom_2")
            shinyjs::show(id = "zoom_3")
        }
    })
    
    
    observeEvent(input$myFile, {
        inFile <- input$myFile
        if (is.null(inFile))
            return()
    
        showModal(modalDialog("Transforming...", footer = NULL, easyClose = FALSE), session = session)
        file_path = inFile$datapath
        
        # check image dimension
        # browser()
        img <- tryCatch({
            readJPEG(file_path) }, error = function(e){
                readPNG(file_path)
            }
        )
        dim = dim(img)
        height = dim[1]
        width = dim[2]
        
        if (width > 500 | height > 500){
            removeModal(session = session)
            
            showModal(modalDialog("Sorry! Due to the limited computation resources, currently we only support image less than 500x500.", 
                                  easyClose = FALSE), 
                      session = session)
        } else {
            file_name = paste0(format(Sys.time(), "%Y%m%d_%H%M%S"), "_", inFile$name)
            if (docker){
                url = "http://api:8050/sr_lapsrn_x8"
            } else {
                url = "http://127.0.0.1:8050/sr_lapsrn_x8"
            }
            out  = run_api(url, file_path, file_name)
            status_code = out[[1]]
            dim = out[[2]]
            
            values$previous_custom_file_name = file_name
            values$file_name = file_name
            values$status_code = status_code   
            
            # browser()
            removeModal(session = session)
        }
        
        
        
        
    })
    
    observe({        
        if (!docker){
            values$file_name = MapExampleToImage(input$dropdown_input)$selected
        }
        
        if (input$radio_input_selection == "example"){
            values$file_name = MapExampleToImage(input$dropdown_input)$selected
        } else {
            previous = values$previous_custom_file_name
            if (!is.null(previous)){
                values$file_name = previous
            }
        }
    })
    
    output$intro = renderUI({
        # # browser()
        # tagList(
        #     tags$img(src = "./test2.jpg", width = 600) # ,
        #     # tags$figure(style = paste0("background-image: url(./test.jpg);"))
        # )
    })

    #### Zoom comparison ===================================================
    observe({
        req(!is.null(values$status_code))

        if (values$status_code == 200){
            # browser()
            file_name = paste0("lapsrn_x8_", values$file_name)
            folder_path = values$folder_path
            before_path = file.path("img", folder_path, file_name, "lr.jpg")
            bicubic_path = file.path("img", folder_path, file_name, "hr_bicubic.jpg")
            after_path = file.path("img", folder_path, file_name, "hr.jpg")
            
            if (!docker){
                if (input$radio_input_selection == "custom") {
                    dir.create(file.path('www/img', folder_path))
                    R.utils::copyDirectory(file.path("../../api/app", folder_path, file_name), 
                                           file.path('www/img', folder_path, file_name), recursive=TRUE)
                }
            }
            
            # browser()
            shinyjs::js$insertImage(before_path, before_path, after_path)
            # browser()
            shinyjs::js$imageZoom("myimage", "myresult")
            shinyjs::js$imageZoom("myimage2", "myresult2")
            shinyjs::js$imageZoom("myimage3", "myresult3")
        }
    })

    #### Side-by-side comparison ===========================================
    output$side_by_side_ui = renderUI({
        req(!is.null(values$status_code))
        
        if (values$status_code == 200){
            file_name = paste0("lapsrn_x8_", values$file_name)
            folder_path = values$folder_path
            
            if (!docker){
                if (input$radio_input_selection == "custom") {
                    dir.create(file.path('www/img', folder_path))
                    R.utils::copyDirectory(file.path("../../api/app/", folder_path, file_name), 
                                           file.path('www/img', folder_path, file_name), recursive=TRUE)
                }
            }
            p = readbitmap::read.bitmap(file.path("www/img", folder_path, file_name, "hr.jpg"))
            
            width = dim(p)[2]
            height = dim(p)[1]
            ratio = width/height
            
            if (ratio > 1.5){
                ui_width = 600
            } else {
                ui_width = 500
            }     
            ui_height = ui_width/ratio
            
            after_path = file.path("img", folder_path, file_name, "hr.jpg")
            before_path = file.path("img", folder_path, file_name, "lr.jpg")
            values$image_finish_trigger = rnorm(1)
            
            tagList(
                fluidRow(
                    column(width = 12,
                           tags$div("Original(Left) vs. Super Resolution (Right)", 
                                    style = "width: 100%;text-align:center;"),
                           tags$div(style = "text-align:center;display:flex;align-items:center;justify-content:center",
                                    tags$div(id = "comparison",
                                             style = paste0("width:", ui_width, "px; height:", ui_height, "px;"),
                                             tags$figure(
                                                 style = paste0("background-image: url(./", after_path, ");"),
                                                 tags$div(id = "divisor",
                                                          style = paste0("background-image: url(./", before_path, ");"))
                                             ),
                                             tags$input(type = "range", min = 0, max = 100,
                                                        value = 50, id = "slider", oninput = "moveDivisor()")
                                    )
                           )
                    )
                )
            )
        } else {
            removeModal(session = session)
            HTML("Something wrong, please contact the maintainer Ting Chou (yintingchou@gmail.com)")
        }
    })

    ##### Download Handeler ======================================
    output$download_ui = renderUI({
        req(!is.null(values$status_code))
        if (values$status_code == 200){
            downloadButton('download', 'Download the 2 images')
        }
    })
    output$download <- downloadHandler(
        filename = function(){
            paste0("lapsrn_x8_", values$file_name,".zip")
        },
        content = function(file){
            file_name = paste0("lapsrn_x8_", values$file_name)
            folder_path = values$folder_path
            path = file.path(getwd(), "www/img", folder_path, file_name)
            print(path)
            temp = setwd(path)
            # temp <- setwd(tempdir())
            on.exit(setwd(temp))
            zip(file, list.files())
        }
    )
})

