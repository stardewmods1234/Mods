    # Exports OreDetails.xlsx into Json format
    # For use with Stardew Valley mod "Discoveries in the Depths" by mikeInside
    
    cls 
    $sheetPath = "$PSScriptRoot\OreDetails.xlsx"

    # Create an Object Excel Application using Com interface  
    $excelObj = New-Object -ComObject Excel.Application  
    # Disable the 'visible' property so the document won't open in excel  
    $excelObj.Visible = $false
    # open WorkBook  
    $workBook = $excelObj.Workbooks.Open("$sheetPath")  
    $excelObj.Workbooks | Select-Object -Property name, author, path 
    # worksheets we will be accessing
    $sheetOptions = $workBook.Sheets.Item("Options")
    $sheetNode = $workBook.Sheets.Item("Node Table")
    $sheetClump = $workBook.Sheets.Item("Clump Table")
    $sheetTemplate = $workBook.Sheets.Item("Template")
        
    # create folder if not exist
    function Make-MiPath {
        [CmdletBinding()]
        param (
            [Parameter(mandatory=$true)][System.IO.FileInfo]$path
        )
        If(!(test-path $path)) {
            # sending to $null to avoid console output is an alternative to | Out-Null, slightly faster
            New-Item -ItemType Directory -Force -Path $path > $null
        }
    }

    # generate and save json for clumps and nodes
    function Generate-MiJson {
        # default params
        [CmdletBinding()]
        param (
            [ValidateNotNullOrEmpty()]
            [decimal]$settingClumpChance = 1.0,
            [decimal]$settingNodeChance = 1.0,
            [decimal]$settingDropChance = 1.0,
            [decimal]$settingDropAmount = 1.0,
            [decimal]$settingLucky = 0.0,
            [decimal]$settingMiner = 0.0,
            [string]$rarity = ""
        )
        
        # set directory paths
        $nodeDirectory = "[CON]TinyDiscoveries"
        $clumpDirectory = "[CRC]BigDiscoveries"

        $nodePath = "$PSScriptRoot\CustomRarity\$rarity\$nodeDirectory"
        $clumpPath = "$PSScriptRoot\CustomRarity\$rarity\$clumpDirectory"
        
        $defaultNodePath = "$PSScriptRoot\..\$nodeDirectory"
        $defaultClumpPath = "$PSScriptRoot"

        # make sure path exists
        Make-MiPath -path $nodePath
        Make-MiPath -path $clumpPath
        
        # change numbers on the options page of the sheet
        $sheetOptions.Range("settingNodeChance").Value = $settingNodeChance
        $sheetOptions.Range("settingClumpChance").Value = $settingClumpChance
        $sheetOptions.Range("settingDropChance").Value = $settingDropChance
        $sheetOptions.Range("settingDropAmount").Value = $settingDropAmount
        $sheetOptions.Range("settingLucky").Value = $settingLucky
        $sheetOptions.Range("settingMiner").Value = $settingMiner
        
        # grab and concatenate node data
        $sheetOptions.Range("settingTitle").Value = "Auto-generated Node Settings $rarity"
        $nodeJson = $sheetTemplate.Range("nodeHeader").Text
        Foreach ($cell in $sheetNode.Range("node[json]")) {
           $nodeJson += $cell.Text
        }
        $nodeJson += $sheetTemplate.Range("nodeFooter").Text
        
        # grab and concatenate clump data
        $sheetOptions.Range("settingTitle").Value = "Auto-generated Clump Settings $rarity"
        $clumpJson = $sheetTemplate.Range("clumpHeader").Text
        Foreach ($cell in $sheetClump.Range("clump[json]")) {
           $clumpJson += $cell.Text
        }
        $clumpJson += $sheetTemplate.Range("clumpFooter").Text
        
        # output json to rarity folder, these are so that the rarity settings can be altered by users without having to edit/run this file
        $nodeJson | Out-File -LiteralPath $nodePath\custom_ore_nodes.json
        $clumpJson | Out-File -LiteralPath $clumpPath\custom_resource_clumps.json

        # if rarity contains the word "default" then also save it in the location that will be used by the mod
        if ($rarity -match "default") {
            $nodeJson | Out-File -LiteralPath $defaultNodePath\custom_ore_nodes.json
            $clumpJson | Out-File -LiteralPath $defaultClumpPath\custom_resource_clumps.json
        }

    }
    


    # Each setting group makes a set of json files saved in separate folder
    Generate-MiJson -settingNodeChance 0.06 -settingClumpChance 0.1 -settingDropChance 0.5 -settingDropAmount 0.5 -settingLucky 0.0 -settingMiner 0.0 -rarity "1_VeryRare"
    Generate-MiJson -settingNodeChance 0.12 -settingClumpChance 0.4 -settingDropChance 0.5 -settingDropAmount 0.5 -settingLucky 0.0 -settingMiner 0.0 -rarity "2_Rare"
    Generate-MiJson -settingNodeChance 0.28 -settingClumpChance 0.8 -settingDropChance 0.8 -settingDropAmount 0.8 -settingLucky 0.0 -settingMiner 0.0 -rarity "3_Uncommon"
    # Default settings for mod
    Generate-MiJson -settingNodeChance 0.48 -settingClumpChance 1.25 -settingDropChance 1.0 -settingDropAmount 1.0 -settingLucky 0.0 -settingMiner 0.0 -rarity "4_Default"
    # More setting groups
    Generate-MiJson -settingNodeChance 0.85 -settingClumpChance 1.6 -settingDropChance 1.2 -settingDropAmount 1.0 -settingLucky 0.0 -settingMiner 0.0 -rarity "5_Abundant"
    Generate-MiJson -settingNodeChance 1.5 -settingClumpChance 2.1 -settingDropChance 1.6 -settingDropAmount 1.1 -settingLucky 1.0 -settingMiner 1.0 -rarity "6_Overpowered"
    Generate-MiJson -settingNodeChance 5.0 -settingClumpChance 5.0 -settingDropChance 4.0 -settingDropAmount 5.0 -settingLucky 1.0 -settingMiner 1.0 -rarity "7_Ridiculous"


    # clean up and close
    $workBook.close($false)
    $excelObj.Quit()
    # release the Sheet objects
    [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($sheetOptions) | Out-Null
    [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($sheetNode) | Out-Null
    [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($sheetClump) | Out-Null
    [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($sheetTemplate) | Out-Null
    # release the WorkSheet Com object
    [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($workBook) | Out-Null
    # release the Excel.Application Com object
    [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($excelObj) | Out-Null 
    # Force garbage collection
    [System.GC]::Collect()
    # Suspend the current thread until the thread that is processing the queue of finalizers has emptied that queue.
    [System.GC]::WaitForPendingFinalizers()
    