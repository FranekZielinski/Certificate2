*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=False
Library             RPA.Tables
Library             RPA.HTTP
Library             OperatingSystem
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.RobotLogListener


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Get orders, fill form, create PDF, take ss
    Zip


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button    css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark

Fill the form
    [Arguments]    ${order}
    Mute Run On Failure    Run Keyword
    Select From List By Value    id:head    ${order}[Head]
    Click Element    id:id-body-${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Click Button    id:preview
    ss    ${order}
    Click Button    id:order
    Wait Until Element Is Visible    id:order-another

Another order
    Click Button    id:order-another

ss
    [Arguments]    ${order}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}receipts${/}${order}[Order number].png
    RETURN    ${OUTPUT_DIR}${/}receipts${/}${order}[Order number].png

Create PDF with ss
    [Arguments]    ${order}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}receipts${/}${order}[Order number].Pdf
    Open Pdf    ${OUTPUT_DIR}${/}receipts${/}${order}[Order number].Pdf
    ${file}=    ss    ${order}
    ${files}=    Create List    ${file}
    Add Files To Pdf
    ...    ${files}
    ...    ${OUTPUT_DIR}${/}receipts${/}${order}[Order number].Pdf
    ...    append=True
    Close Pdf    ${OUTPUT_DIR}${/}receipts${/}${order}[Order number].Pdf

Get orders, fill form, create PDF, take ss
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    @{orders}=    Read table from CSV    orders.csv    header=True
    Wait Until Element Is Visible    id:head
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Wait Until Keyword Succeeds    50x    0.5 s    Fill the form    ${order}
        Create PDF with ss    ${order}
        Another order
    END

Zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.Zip
