## Title:           Set-Termination
## Author:          Derrek Schuurman derrekschuurman@gmail.com
## Created Date:    9/04/2018
## Last Edit:       Derrek Schuurman
## Updat Date:      9/19/2018




## Notes
## Manager change part has been taken out. At the current moment this changes the manager of all direct reports to the amanager that the terminated employee had. 
## Looks gross. The functions are at the bottom of the script.
##
## How to run ---> Set-Termination -userList "Ed Nuno, Derrek Schuurman"
## END NOTES




 Param(
        [Parameter(Mandatory=$true)]
        [string]$userList
      )

   
   ## Int Full name Array
   $userArray = @()



    ## Breaks up the userList into seperate useable objects
    $userArray = $userList -split ", "

    $length = $userArray.Length

    ## Int Login name Array
    $userArrayLogin = @()*$length

    ## Loop to convert full names into login names and store them into array
    for($i=0;$i -lt $length;$i++)
        {
            $name = $userArray[$i]

            Write-Output "NAME"$name
            $userArrayLogin += (Get-ADUser -filter "DisplayName -eq '$($name)'" | Select samAccountName).SamAccountName
       
            Write-Output ("`n Checking for user " + $userArray[$i])

            if($userArrayLogin[$i] -eq $null)
            {
                Write-Output ("`n Could not find user " + $userArray[$i] + " .....Aborting")
                exit  
            }
            else
            {
                Write-Output ("`n Found user " + $userArray[$i])              
            }

        }


        ## Direct Report loop
        for($i=0;$i -lt $length;$i++)
        {
            ##Detect Direct Reports
            $drCheck = get-aduser $userArray[$i] -properties * | select -Expand directreports
   
                if($drcheck -eq $null)
                {
                    Write-Output "No Direct reports to configure for " $userArrayLogin[$i]
                }
                else
                {
                    Set-DirectReports -user $userArrayLogin[$i]
                }
        }

        ## Termination Loop
        for($i=0;$i -lt $length;$i++)
        {
        Start-Termination -user $userArrayLogin[$i] -fullName $userArray[$i]
        Set-Notes -task 'Termination' -user $userArrayLogin[$i] 

        Write-Output "Program is finished"

        }

      
Function Set-Notes
{
    Param (
    [string]$task,
    [string]$user
    )

    $note = (Get-ADUser $user -Properties info).info

    $newLine = (Get-Date -UFormat "%Y.%m.%d") + "-" + $Task + "-" + $env:UserName

    Set-ADUser $user -Replace @{info="$($note)`r`n $($newLine)"}
   
}

Function Move-Manager
{
   Param(
    [string]$termUserLogin
    )

    $managerLogin = (get-aduser (get-aduser $termUserLogin -Properties manager).manager).samaccountName

    $reportArrayLogin = @(Get-ADUser -Identity $termUser -Properties directreports | Select-Object -ExpandProperty directreports | Get-ADUser -Properties mail | Select-Object SamAccountName)
    $length = $reportArrayLogin.Length

        for($i=0;$i -lt $length; $i++)
        {
             Set-ADUser $reportArrayLogin[$i] -Manager $managerLogin
             Set-Notes -task 'TerminationManagerChange' -user $reportArrayLogin[$i]
        }

 }

Function Start-Termination
{
    Param(
    [string]$user,
    [string]$fullName
    )  
            $disabledPath = 'OU=Disabled-Terminated,OU=Accounts and Groups,DC=mba,DC=xifin,DC=com'
            $disabledPassword = "Y0uH@veB33nTerm!n@t3d"
            $sam = net user $user /domain

            if($sam -eq $null)
            {
                Write-Output "Error - User not found in Active Directory"
            }
            else
            {
                $date = Get-Date -UFormat "%Y%m%d"
                $tLine = "z_do_not_reply_" + $date + "_" + ($fullName.replace(' ',''))

                ## Display Name
                Set-ADUser $user -DisplayName $tLine

                ## Description
                Set-ADUser $user -Description $tLine

                ## Office
                Set-ADUser $user -Office $null

                ## Telephone number
                Set-ADUser $user -OfficePhone $null

                ## Email
                Set-ADUser $user -Email $null

                ## Remove Phone Number
                Set-ADUser $user -Clear ipPhone

                ## Job Title/Department/Company
                Set-ADUser $user -Department $null -Title $tLine -Company $null

                ## Manager
                Set-ADUser $user -Manager $null

                ## Reset Users Password to a new one
                Set-ADAccountPassword -Identity $user -NewPassword (ConvertTo-SecureString -AsPlainText $disabledPassword -Force)

                ##Gets rid of password never expiring
                Set-ADUser -Identity $user -PasswordNeverExpires:$false

                ## Force Password Change on next login
                Set-ADUser $user -ChangePasswordAtLogon:$true

                ## Remove group membership (found this magic online)
                Get-ADUser -Identity $user -Properties MemberOf | ForEach-Object {$_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false }

                ## Gets AD PAth
                $dn = get-aduser $user -properties * | select -Expand DistinguishedName

                ## Moves user to the disabled OU
                Move-ADObject -Identity $dn -targetpath $disabledPath

                ## Disable Account
                Disable-ADAccount -Identity $user

                Write-Output "User " + $fullName + " has been terminated"
            }
}