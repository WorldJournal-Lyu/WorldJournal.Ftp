<#

WorldJournal.Ftp.psm1

    2018-06-05 Initial creation
    2018-06-07 Added 'WebClient-UploadFile', 'WebClient-DownloadFile'
    2018-06-08 Added 'WebRequest-UploadFile'

#>


function WebRequest-UploadFile {
    param(
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [Parameter(Mandatory=$true)][string]$RemoteFilePath,
        [Parameter(Mandatory=$true)][string]$LocalFilePath
    )

    $localFileContent = Get-Content $LocalFilePath -Encoding Byte

    $ftpWebRequest = [System.Net.FtpWebRequest]::Create($RemoteFilePath)
    $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftpWebRequest.UseBinary = $true
    $ftpWebRequest.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
    $ftpWebRequest.ContentLength = $localFileContent.Length

    try{

        $requestStream = $ftpWebRequest.GetRequestStream()
        $requestStream.Write($localFileContent, 0, $localFileContent.Length)
        $requestStream.Close()
        $response = $ftpWebRequest.GetResponse()    

        $returnParam = @{
            Verb    = "Upload"
            Noun    = ($response.StatusDescription).substring(0, ($response.StatusDescription).Length-3)
            Status  = "Good"
        }

    }catch{

        $returnParam = @{
            Verb    = "Upload"
            Noun    = $_.Exception.Message
            Status  = "Bad"
        }

    }

    $response.Close()
    return $returnParam
}


Function WebClient-UploadFile() {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [Parameter(Mandatory=$true)][string]$RemoteFilePath,
        [Parameter(Mandatory=$true)][string]$LocalFilePath
    )

    $webClient = New-Object System.Net.WebClient 
    $webClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)  
    $uri       = New-Object System.Uri($RemoteFilePath) 

    try{
        $webClient.UploadFile($uri, $LocalFilePath)
        $returnParam = @{
            Verb    = "Upload"
            Noun    = "Complete"
            Status  = "Good"
        }

    }catch{
        $returnParam = @{
            Verb    = "Upload"
            Noun    = $_.Exception.Message
            Status  = "Bad"
        }
    }

    return $returnParam

}

Function WebClient-DownloadFile() {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [Parameter(Mandatory=$true)][string]$RemoteFilePath,
        [Parameter(Mandatory=$true)][string]$LocalFilePath
    )

    $webClient = New-Object System.Net.WebClient 
    $webClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)  

    try{
        $webClient.DownloadFile($RemoteFilePath, $LocalFilePath)
        $returnParam = @{
            Verb    = "Download"
            Noun    = "Complete"
            Status  = "Good"
        }
    }catch{
        $returnParam = @{
            Verb    = "Download"
            Noun    = $_.Exception.Message
            Status  = "Bad"
        }
    }

    return $returnParam

}
