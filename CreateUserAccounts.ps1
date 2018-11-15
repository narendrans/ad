# Author: Naren (naren@dremio.com)
# Code is for POC only. Use it at your own risk ;)

#Import Active Directory Module
Import-module activedirectory

#Autopopulate Domain
$dnsDomain =gc env:USERDNSDOMAIN
$split = $dnsDomain.split(".")
if ($split[2] -ne $null) {
	$domain = "DC=$($split[0]),DC=$($split[1]),DC=$($split[2])"
} else {
	$domain = "DC=$($split[0]),DC=$($split[1])"
}

#Declare any Variables
$dirpath = $pwd.path
$orgUnit = "CN=Users"
$dummyPassword = ConvertTo-SecureString -AsPlainText "dremio123!@#" -Force
$counter = 0

#import CSV File
$ImportFile = Import-csv "$dirpath\ADUsers.csv"
$TotalImports = $importFile.Count

#Create Users
$ImportFile | foreach {
	$counter++
	$progress = [int]($counter / $totalImports * 100)
	Write-Progress -Activity "Provisioning User Accounts" -status "Provisioning account $counter of $TotalImports" -perc $progress
	if ($_.Manager -eq "") {
		New-ADUser -UserPrincipalName $_.mail -SamAccountName $_.SamAccountName -Name $_.Name -Surname $_.Sn -GivenName $_.GivenName -Path "$orgUnit,$domain" -AccountPassword $dummyPassword -Enabled $true -title $_.title -officePhone $_.officePhone -department $_.department -emailaddress $_.mail -EmployeeID $_.employeeid -PasswordNeverExpires $true
	} else {
    New-ADUser -UserPrincipalName $_.mail -SamAccountName $_.SamAccountName -Name $_.Name -Surname $_.Sn -GivenName $_.GivenName -Path "$orgUnit,$domain" -AccountPassword $dummyPassword -Enabled $true -title $_.title -officePhone $_.officePhone -department $_.department -manager "$($_.Manager),$orgUnit,$domain" -emailaddress $_.mail -EmployeeID $_.employeeid -PasswordNeverExpires $true
	}
	If (gci "$dirpath\userimages\$($_.name).jpg") {
		$photo = [System.IO.File]::ReadAllBytes("$dirpath\userImages\$($_.name).jpg")
		Set-ADUSER $_.samAccountName -Replace @{thumbnailPhoto=$photo}
	}
}

#Create Groups
New-ADGroup -Name "Department" -GroupScope Global
New-ADGroup -Name "Executive" -GroupScope Global
New-ADGroup -Name "Operations" -GroupScope Global
New-ADGroup -Name "Project Management" -GroupScope Global
New-ADGroup -Name "Engineering" -GroupScope Global
New-ADGroup -Name "Accounting" -GroupScope Global
New-ADGroup -Name "Sales" -GroupScope Global
New-ADGroup -Name "Human Resources" -GroupScope Global
New-ADGroup -Name "Strategy Consulting" -GroupScope Global
New-ADGroup -Name "Sales Engagement Management" -GroupScope Global
New-ADGroup -Name "Senior Management" -GroupScope Global
New-ADGroup -Name "Marketing" -GroupScope Global
New-ADGroup -Name "Content Management Consulting" -GroupScope Global
New-ADGroup -Name "Engineering Operations" -GroupScope Global
New-ADGroup -Name "CRM Strategy" -GroupScope Global
New-ADGroup -Name "Creative" -GroupScope Global
New-ADGroup -Name "1099 Contractor" -GroupScope Global
New-ADGroup -Name "CVP of IT" -GroupScope Global

#Assign users to the groups
$counter = 0

#import CSV File
$dirpath = $pwd.path
$ImportFile = Import-csv "$dirpath\ADUsers.csv"
$TotalImports = $importFile.Count

$ImportFile | foreach {
    $counter++
	$progress = [int]($counter / $TotalImports * 100)
	Write-Progress -Activity "Assigning users to groups" -status "Assigning user $counter of $TotalImports" -perc $progress
    Add-ADGroupMember -Identity $_.department -Members $_.SamAccountName
}