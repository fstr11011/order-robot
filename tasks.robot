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
Library           RPA.PDF

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=    5x
${GLOBAL_RETRY_INTERVAL}=    3.0s

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
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
    ${head}=    Set Variable    ${row}[Head]
    ${body}=    Set Variable    ${row}[Body]
    ${legs}=    Set Variable    ${row}[Legs]
    ${address}=    Set Variable    ${row}[Address]
    Select From List By Index    alias:Select Head    ${head}
    Click Element    locator=id:id-body-${body}
    Input Text    locator=alias:Select Legs    text=${legs}
    Input Text    locator=alias:Input Shipping Address    text=${address}

Preview the robot
    Wait Until Page Contains Element    locator=xpath://*[@id="preview"]
    Click Button    locator=xpath://*[@id="preview"]
    Wait Until Page Contains Element    locator=xpath://*[@id="robot-preview-image"]

Submit the order
    Wait Until Keyword Succeeds
    ...    ${GLOBAL_RETRY_AMOUNT}
    ...    ${GLOBAL_RETRY_INTERVAL}
    ...    Click the submit order button

Click the submit order button
    Click Button    locator=xpath://*[@id="order"]
    Wait Until Element Is Visible    locator=id:receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt}=    Get Element Attribute    locator=id:receipt    attribute=outerHTML
    ${pdf_file}=    Set Variable    ${OUTPUT_DIR}${/}receipts${/}${order_number}_Receipt.pdf
    Html To Pdf    content=${receipt}    output_path=${pdf_file}
    [Return]    ${pdf_file}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${robot_screenshot}=    Set Variable    ${OUTPUT_DIR}${/}screenshots${/}${order_number}_Robot_Screenshot.png
    Screenshot    locator=xpath://*[@id="robot-preview-image"]    filename=${robot_screenshot}
    [Return]    ${robot_screenshot}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    source_path=${pdf}
    ${files}=    Create List    ${screenshot}:align=center
    Add Files To Pdf    files=${files}    target_document=${pdf}    append=True
    Close Pdf    source_pdf=${pdf}

Go to order another robot
    Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Click the order another robot button

Click the order another robot button
    Click Button    locator=id:order-another
