library(shiny)
library(sf)
library(leaflet)

nc <- st_read(system.file("shape/nc.shp", package="sf"))

ui <- fluidPage(
    titlePanel("inputMap in Shiny"),
    sidebarLayout(
        sidebarPanel(
            # Step 2
            leafletOutput("inputMap", height = 200)
        ),
        mainPanel(
           dataTableOutput("filteredResults")
        )
    )
)

server <- function(input, output, session) {
    rv <- reactiveValues()
    # Step 2
    output$inputMap <- renderLeaflet({
        # Step 1
        leaflet(nc,
               options = leafletOptions(
                   zoomControl = FALSE,
                   dragging = FALSE,
                   minZoom = 6,
                   maxZoom = 6) ) %>%
        addPolygons(
            layerId = ~NAME,
            label = ~NAME,
            fillOpacity = .1,
            highlight = highlightOptions(
                fillOpacity = 1,
                bringToFront = TRUE) )
    })
    # Step 3
    observeEvent(input$inputMap_shape_click, {
        click <- input$inputMap_shape_click
        req(click)
        
        rv$nc <- filter(nc, NAME == click$id)
        
        leafletProxy("inputMap", session, data = rv$nc) %>% 
            removeShape("selected") %>% 
            addPolygons(layerId = "selected",
                        fillColor = "red",
                        fillOpacity = 1)
    })
    output$filteredResults <- renderDataTable({
        if (is.null(rv$nc)){
            return(st_set_geometry(nc, NULL))
        } else {return(st_set_geometry(rv$nc, NULL))}
    })
}

shinyApp(ui = ui, server = server)