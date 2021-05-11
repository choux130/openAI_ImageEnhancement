shinyUI(
    ui = bs4DashPage(
        old_school = FALSE,
        sidebar_collapsed = TRUE,
        controlbar_collapsed = FALSE,
        title = "AI - Image Enhancement",
        sidebar = bs4DashSidebar(
            skin = "light",
            status = "primary",
            title = "AI - Image Enhancement",
            brandColor = "primary",
            elevation = 3,
            opacity = 0.8,
            bs4SidebarMenu(
                bs4SidebarMenuItem("About", tabName = "tab_intro", icon = "book"),
                bs4SidebarMenuItem("Try it!", tabName = "tab_tryit", icon = "futbol") 
            )
        ),
        body = bs4DashBody(
            shinyjs::useShinyjs(),
            shinyjs::extendShinyjs(text = jsCode, functions = c("insertImage")),
            shinyjs::extendShinyjs(text = jsCode2, functions = c("imageZoom")),
            tags$head(tags$script(js)),
            tags$head(tags$link(rel = "stylesheet", 
                                type = "text/css", 
                                href = "style.css")), 
            bs4TabItems(
                bs4TabItem(
                    tabName = "tab_intro",
                    bs4Card(width = 12, closable = FALSE, 
                            title = "Welcome!", 
                            status = "primary", 
                            bordered = TRUE, 
                            solidHeader = TRUE,
                            uiOutput("intro"))
                ),
                bs4TabItem(
                    tabName = "tab_tryit",
                    fluidRow(
                        column(width = 2, 
                        bs4Card(
                            width = 12,
                            title = "Control Options",
                            closable = FALSE,
                            solidHeader = TRUE,
                            fluidRow(
                               radioButtons(
                                   inputId = "radio_input_selection",
                                   label = "Input image:",
                                   choiceNames = c("Example", "Custom"),
                                   choiceValues = c("example", "custom"),
                                   selected = "example",
                                   inline = TRUE
                               ),
                               conditionalPanel(
                                   condition = "input.radio_input_selection == 'example'",
                                   selectInput(
                                       width = "100%",
                                       inputId = "dropdown_input",
                                       label = "Select an example image:",
                                       choices = c("Example 1",
                                                   "Example 2",
                                                   "Example 3",
                                                   "Example 4")
                                   )
                               ),
                               conditionalPanel(
                                   condition = "input.radio_input_selection == 'custom'",
                                   fileInput(inputId = "myFile",
                                             label = "Choose a file:",
                                             accept = c('image/png', 'image/jpeg')
                                   )
                               ),
                               uiOutput("download_ui")
                            )
                        )
                    ),
                    column(width = 10, 
                        bs4Card(
                            width = 12,
                            title = "Side-by-side",
                            closable = FALSE, 
                            collapsed = TRUE,
                            status = "primary",
                            maximizable = TRUE,
                            uiOutput("side_by_side_ui")
                        ),
                        bs4Card(
                            width = 12,
                            title = "Zoom",
                            closable = FALSE, 
                            maximizable = TRUE,
                            status = "primary",
                            fluidRow(
                               column(width = 6,
                                      fluidRow(
                                          tags$div(
                                              class = "img-zoom-container",
                                              tags$img(
                                                  id = "myimage",
                                                  width = 300
                                              )),
                                          tags$div(
                                              id = "myresult",
                                              class = "img-zoom-result"
                                          )
                                      )
                               ),
                               column(width = 6,
                                      fluidRow(
                                          tags$div(
                                              class = "img-zoom-container",
                                              tags$img(
                                                  id = "myimage2",
                                                  width = 300)),
                                          tags$div(
                                              id = "myresult2",
                                              class = "img-zoom-result"
                                          )
                                      )
                               )
                           )
                         )
                    ))
                )
            )
        )
    )
)
