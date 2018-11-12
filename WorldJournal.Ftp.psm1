<#

WorldJournal.Ftp.psm1

    2018-06-05 Initial creation
    2018-06-07 Added 'WebClient-UploadFile', 'WebClient-DownloadFile'
    2018-06-08 Added 'WebRequest-UploadFile' (testing)

#>



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
    $uri = New-Object System.Uri($RemoteFilePath) 
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Verb –value "UPLOAD"
    $obj | Add-Member -MemberType NoteProperty -Name Noun –value $RemoteFilePath

    try{
        $webClient.UploadFile($uri, $LocalFilePath)
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Good"
    }catch{
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Bad"
        $obj | Add-Member -MemberType NoteProperty -Name Exception –value $_.Exception.Message
    }

    Write-Output $obj

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
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Verb –value "DOWNLOAD"
    $obj | Add-Member -MemberType NoteProperty -Name Noun –value $LocalFilePath

    try{
        $webClient.DownloadFile($RemoteFilePath, $LocalFilePath)
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Good"
    }catch{
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Bad"
        $obj | Add-Member -MemberType NoteProperty -Name Exception –value $_.Exception.Message
    }

    Write-Output $obj

}

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


    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Verb –value "UPLOAD"
    $obj | Add-Member -MemberType NoteProperty -Name Noun –value $RemoteFilePath

    try{

        $requestStream = $ftpWebRequest.GetRequestStream()
        $requestStream.Write($localFileContent, 0, $localFileContent.Length)
        $requestStream.Close()
        $response = $ftpWebRequest.GetResponse()    
        $response.Close()
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Good"

    }catch{

        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Bad"
        $obj | Add-Member -MemberType NoteProperty -Name Exception –value $_.Exception.Message

    }

    $response.Close()
    Write-Output $obj
}




function WebRequest-RemoveFile {
    param(
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [Parameter(Mandatory=$true)][string]$RemoteFilePath
    )

    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Verb –value "REMOVE"
    $obj | Add-Member -MemberType NoteProperty -Name Noun –value $RemoteFilePath

    try{
        $ftpWebRequest = [System.Net.FtpWebRequest]::Create($RemoteFilePath)
        $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
        $ftpWebRequest.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
        $response = $ftpWebRequest.GetResponse()
        $response.Close()
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Good"
    }catch{
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Bad"
        $obj | Add-Member -MemberType NoteProperty -Name Exception –value $_.Exception.Message
    }

    Write-Output $obj
}

function WebRequest-RemoveFolder {
    param(
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [Parameter(Mandatory=$true)][string]$RemoteFolderPath
    )

    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Verb –value "REMOVE"
    $obj | Add-Member -MemberType NoteProperty -Name Noun –value $RemoteFolderPath

    try{
        $ftpWebRequest = [System.Net.FtpWebRequest]::Create($RemoteFolderPath)
        $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::RemoveDirectory
        $ftpWebRequest.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
        $response = $ftpWebRequest.GetResponse()
        $response.Close()
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Good"
    }catch{
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Bad"
        $obj | Add-Member -MemberType NoteProperty -Name Exception –value $_.Exception.Message
    }

    Write-Output $obj
}

function WebRequest-ListDirectory {
    param(
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [Parameter(Mandatory=$true)][string]$RemoteFolderPath
    )

    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Verb –value "LIST"
    $obj | Add-Member -MemberType NoteProperty -Name Noun –value $RemoteFolderPath

    try{
        $ftpWebRequest = [System.Net.FtpWebRequest]::Create($RemoteFolderPath)
        $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
        $ftpWebRequest.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
        $response = $ftpWebRequest.GetResponse()

        $responseStream = $response.GetResponseStream()
        $streamReader = New-Object System.IO.StreamReader $responseStream  
   
        $files = New-Object System.Collections.ArrayList
        While ($file = $streamReader.ReadLine()){
            if( ($file -ne ".") -and ($file -ne "..") ){
                [void] $files.add("$file")
            }
        }
        $streamReader.close()
        $responseStream.close()
        $response.Close()

        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Good"
        $obj | Add-Member -MemberType NoteProperty -Name List –value $files

    }catch{
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Bad"
        $obj | Add-Member -MemberType NoteProperty -Name Exception –value $_.Exception.Message
    }

    Write-Output $obj
}

function WebRequest-TestPath {
    param(
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [Parameter(Mandatory=$true)][string]$RemoteFolderPath
    )

    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Verb –value "TEST-PATH"
    $obj | Add-Member -MemberType NoteProperty -Name Noun –value $RemoteFolderPath

    try{
        $ftpWebRequest = [System.Net.FtpWebRequest]::Create($RemoteFolderPath)
        $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
        $ftpWebRequest.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
        $response = $ftpWebRequest.GetResponse()
        $response.Close()
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Good"
    }catch{
        $obj | Add-Member -MemberType NoteProperty -Name Status –value "Bad"
        $obj | Add-Member -MemberType NoteProperty -Name Exception –value $_.Exception.Message
    }

    Write-Output $obj
}