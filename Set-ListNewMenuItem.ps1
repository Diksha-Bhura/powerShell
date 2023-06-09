<#
.SYNOPSIS
Set the New Menu on a document library.

.DESCRIPTION
Sets the New Menu on a document libary, allow you to hide content types you don't want to show. This will grab all list content types currently assigned to the library.

Default Content Types used by Microsoft 'Folder', 'Word document', 'Excel workbook', 'PowerPoint presentation', 'OneNote notebook' 'Visio drawing', 'Link'

.EXAMPLE
Updates the SharePoint library New Menu, but hiding Default Content Types ('Word document', 'Excel workbook', 'PowerPoint presentation', 'OneNote notebook' 'Visio drawing') and given Content Types

-Url:'https://tenant.sharepoint.com/sites/demo' -ListTitle:'Documents' -ContentTypesToHide:'OneNote notebook','Link' -HideDefault:$true


#>
function Add-MenuItem() {
    param(
        [Parameter(Mandatory)]
        $title,
        [Parameter(Mandatory)]
        $visible,
        [Parameter(Mandatory)]
        $templateId,
        [Parameter()]
        $contentTypeId
    )
    
    $newChildNode = New-Object System.Object
    $newChildNode | Add-Member -type NoteProperty -name title -value:$title
    $newChildNode | Add-Member -type NoteProperty -name visible -value:$visible
    $newChildNode | Add-Member -type NoteProperty -name templateId -value:$templateId
    if ($null -ne $contentTypeId) {
        $newChildNode | Add-Member -type NoteProperty -name contentTypeId -value:$contentTypeId
        $newChildNode | Add-Member -type NoteProperty -name isContentType -value:$true
    }

    return $newChildNode
}

function Get-DefaultMenuItems() {
    $DefaultMenuItems = @()
    $DefaultMenuItems += Add-MenuItem -title:"Folder" -templateId:"NewFolder" -visible:$true
    $DefaultMenuItems += Add-MenuItem -title:"Word document" -templateId:"NewDOC" -visible:$true
    $DefaultMenuItems += Add-MenuItem -title:"Excel workbook" -templateId:"NewXSL" -visible:$true
    $DefaultMenuItems += Add-MenuItem -title:"PowerPoint presentation" -templateId:"NewPPT" -visible:$true
    $DefaultMenuItems += Add-MenuItem -title:"OneNote notebook" -templateId:"NewONE" -visible:$true
    $DefaultMenuItems += Add-MenuItem -title:"Visio drawing" -templateId:"NewVSDX" -visible:$true
    $DefaultMenuItems += Add-MenuItem -title:"Forms for Excel" -templateId:"NewXSLForm" -visible:$true
    $DefaultMenuItems += Add-MenuItem -title:"Link" -templateId:"Link" -visible:$true
   
    return $DefaultMenuItems
}

function Set-NewMenuOnList() {
    
        
    
    
    Connect-PnPOnline -Url "https://bsdevdb.sharepoint.com/sites/bsoneQM060" -UseWebLogin
    Write-Host "Connected to URL:$Url" -ForegroundColor Green

    $list = Get-PnpList -Identity "bsoneProcessDocuments"
    Write-Host "Connected to List:bsoneProcessDocuments"
    $listContentTypes = Get-PnPContentType -List $list
    $defaultView = Get-PnpView -List:$list | Where-Object {$_.DefaultView -eq $true}
    $MenuItems = Get-DefaultMenuItems
    $listContentTypes | ForEach-Object {
        $ct = $PSItem
        if($ct.Name -eq "Folder"){
          return
        }

        $MenuItems += Add-MenuItem -title:$ct.Name -visible:$true -templateId:$ct.StringId -contentTypeId:$ct.StringId
    }


    $MenuItems | ForEach-Object {
        if ($hideContentType -contains ($_.title)) {
            $_.visible = $false
            write-host "Hiding content type $($_.title)" -ForegroundColor Yellow
        }
        else {
            write-host "Showing $($_.title)" -ForegroundColor Green
        }
    } 
    
    $defaultView.NewDocumentTemplates = $menuItems | ConvertTo-Json
    $defaultView.Update()
    Invoke-PnPQuery
    Write-Host "Updated $($list.Title)" 
}


Set-NewMenuOnList -URL:$URL -ListTitle:$ListTitle -ContentTypesToHide:$ContentTypesToHide -HideDefault:$HideDefault
