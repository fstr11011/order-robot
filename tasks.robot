*** Settings ***
Documentation
...               Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Dialogs
Library           Dialogs

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Log    ${row}
        Close the annoying modal
        Fill the form    ${row}
        # Preview the robot
        # Submit the order
        # ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        # ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        # Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        # Go to order another robot
    END
    # Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser    url=https://robotsparebinindustries.com/    browser_selection=chrome    maximized=False
    Input Text    locator=alias:Username    text=maria    clear=True
    Input Password    locator=alias:Password    password=thoushallnotpass    clear=True
    Submit Form
    Wait Until Page Contains Element    locator=alias:Order robot tab
    Click Link    locator=alias:Order robot tab
    Wait Until Page Contains Element    locator=alias:Build and order your robot header

Get orders
    Download    url=https://robotsparebinindustries.com/orders.csv    overwrite=True    target_file=orders.csv
    ${orders_table}=    Read table from CSV    path=orders.csv    header=True
    [Return]    ${orders_table}

Close the annoying modal
    Click Element If Visible    locator=alias:I guess so modal button

Fill the form
    [Arguments]    ${row}
    ${order_number}=    Set Variable    ${row}[Order number]
    ${head}=    Set Variable    ${row}[Head]
    ${body}=    Set Variable    ${row}[Body]
    ${legs}=    Set Variable    ${row}[Legs]
    ${address}=    Set Variable    ${row}[Address]
    Select From List By Index    alias:Select Head    ${head}
    Click Element    locator=id:id-body-${body}
    Input Text    locator=alias:Select Legs    text=${legs}
    Input Text    locator=alias:Input Shipping Address    text=${address}
