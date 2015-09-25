# 25-Septembre-2015,v0.41
# author: teiva rodiere
# Syntax:
#	.\doco-downloader.ps1 -docoURLs "https://www.vmware.com/support/pubs/","https://www.vmware.com/support/pubs/vsphere-esxi-vcenter-server-6-pubs.html" -outputDir "C:\admin\vendor-doco\VMware"
#	.\doco-downloader.ps1 -docoURLs "https://www.vmware.com/support/pubs/","https://www.vmware.com/support/pubs/vsphere-esxi-vcenter-server-6-pubs.html" -fileType "\.epub" -quiet $true -pauseOnFaults $false
#
param( 
	[Parameter(ValueFromPipelineByPropertyName=$true)][string[]]$docoURLs, 
	[bool]$forceDownload=$false, 
	[string]$fileType="\.pdf", # options: \.epud,\.modi,\.pdf
	[string]$restrictTo, #"/support/pubs",
	[bool]$quiet=$false,
	[bool]$pauseOnFaults=$false,
	[bool]$deleteEmptyFolders=$true,
	[string]$outputDir=$PWD
)

Set-Variable -Name "quieter" -Scope Global -Value $quiet

#function
function logThis ([string]$msg,[string]$colour="green")
{
	if (!$global:quiet)
	{
		Write-Host $msg -ForegroundColor $colour
	}
	
	# log to this file ?	
}

###########################
if (!(Test-Path -Path $outputDir))
{
	[IO.Directory]::CreateDirectory($outputDir)
}

# troll the lot
$docoURLs | %{
	$docoURI=$_
	$httpReturnCodeUrl = Invoke-WebRequest -uri $docoURI -method head -ErrorAction SilentlyContinue
	if (!$httpReturnCodeUrl -or $httpReturnCodeUrl.StatusCode -ne 200){
		# Something other than "OK" was returned.
		logThis -msg "`t >> Invalid Link $sublinkLvl2.." -colour Red
		if ($pauseOnFaults)
		{
			pause
		}
	} else {
		$mainPage = Invoke-WebRequest -Uri $docoURI -ErrorAction SilentlyContinue
		$mainPage.links.href | ?{$_ -match "\.htm*" -and $_ -match $restrictTo} | %{
			if ($_ -match "http")
			{
				$sublinkLvl1 = $_
			} else {
				$sublinkLvl1 = "$($([System.Uri]$docoURI).scheme)://$($([System.Uri]$docoURI).host)$_"
			}
			logThis -msg "Processing $sublinkLvl1.."
			#$sublinkLvl1Dir = "$PWD\$(($sublinkLvl1 -split '/' | select -Last 1) -replace '.html')"
			
			$httpReturnCodeSubLink1 = Invoke-WebRequest -uri $sublinkLvl1 -method head -ErrorAction SilentlyContinue
			if (!$httpReturnCodeSubLink1 -or $httpReturnCodeSubLink1.StatusCode -ne 200){
				# Something other than "OK" was returned.
				logThis -msg "`t >> Invalid Link $sublinkLvl2.." -colour  Red
				if ($pauseOnFaults)
				{
					pause
				}
			} else {
				$sublinkLvl1Page = Invoke-WebRequest -Uri $sublinkLvl1  -ErrorAction SilentlyContinue
				#$sublinkLvl1Dir = "$outputDir\$($($($([regex]::match($sublinkLvl1Page.Content,'(?<=\<title\>).+(?=\</title\>)','singleline').value.trim())) -replace '<title>' -replace '</title>' -replace ':',' - ').Trim())" 
				$sublinkLvl1Dir = "$outputDir\$([regex]::match($sublinkLvl1Page.Content,'(?<=\<title\>).+(?=\</title\>)').Value)"
				#$outputDir\$($($($([regex]::match($sublinkLvl1Page.Content,'(?<=\<title\>).+(?=\</title\>)','singleline').value.trim())) -replace '<title>' -replace '</title>' -replace ':',' - ').Trim())
				#
				$files=$sublinkLvl1Page.Links.href | Where {$_ -match $fileType}
				#$files
				#$sublinkLvl1Page.Links.href
				#
				if ($files)
				{
					logThis -msg "`tWill download files to folder $sublinkLvl1Dir.."
				}
				$files | %{		
					#logThis -msg "`tlink (Before) = $_"
					#pause
					if ($_ -match "http")
					{
						$sublinkLvl2=$_
					} else {
						$sublinkLvl2 = "$($([System.Uri]$docoURI).scheme)://$($([System.Uri]$docoURI).host)$_"
					}
					if (!(Test-Path -Path $sublinkLvl1Dir))
					{
						logThis -msg "`tCreating folder $sublinkLvl1Dir because it is missing.."
						[IO.Directory]::CreateDirectory("$sublinkLvl1Dir")
					} #else {
						#logThis -msg "`t Folder $sublinkLvl1Dir already exists, reusing it as target for $fileType.."
					#}
					$filename = "$sublinkLvl1Dir\$($sublinkLvl2 -split '/' | select -Last 1)"		
					#logThis -msg "`tOutput file = $filename"
					
					if ((Test-Path $filename) -and $forceDownload)
					{
						#logThis -msg "File already exists, but forcing an update"
						logThis -msg "`tDownloading $sublinkLvl2.."
						$httpReturnCodeSubLink2 = Invoke-WebRequest -uri $sublinkLvl2 -method head  -ErrorAction SilentlyContinue
						if (!$httpReturnCodeSubLink2 -or $httpReturnCodeSubLink2.StatusCode -ne 200){
		    				# Something other than "OK" was returned.
							logThis -msg "`t >> Invalid Link $sublinkLvl2.."
							if ($pauseOnFaults)
							{
								pause
							}
						} else {
							Invoke-WebRequest -uri $sublinkLvl2 -OutFile $filename  -ErrorAction SilentlyContinue
						}						
					} elseif ( !(Test-Path $filename)) {
						#logThis -msg "File does not exist, downloading it.."
						logThis -msg "`tDownloading $sublinkLvl2.."
						#Invoke-WebRequest -Uri $sublinkLvl2 -OutFile $filename
						$httpReturnCodeSubLink2 = Invoke-WebRequest -uri $sublinkLvl2 -method head  -ErrorAction SilentlyContinue
						if (!$httpReturnCodeSubLink2 -or $httpReturnCodeSubLink2.StatusCode -ne 200){
		    				# Something other than "OK" was returned.
							logThis -msg "`t >> Invalid Link $sublinkLvl2.." -colour  Red
							if ($pauseOnFaults)
							{
								pause
							}
						} else {
							Invoke-WebRequest -uri $sublinkLvl2 -OutFile $filename  -ErrorAction SilentlyContinue
						}
					} else {
						logThis -msg "`tSkipping - $sublinkLvl2.." -colour  Yellow
					}
					#pause
				}
			}
			if ($httpReturnCodeSubLink2) { Remove-Variable  httpReturnCodeSubLink2 }
			if ($httpReturnCodeSubLink1) { Remove-Variable  httpReturnCodeSubLink1 }

		}
	}
}

# post clean ups, delete empty folders
if ($deleteEmptyFolders)
{
	Get-ChildItem -Path $outputDir | ?{$_.PSIsContainer -eq $true -and (Get-ChildItem -Path $_.FullName) -eq $null} | Remove-Item #-WhatIf
}
