Add-type -AssemblyName system.windows.forms

#Create form
$form = New-Object system.windows.forms.form
$form.text = "form"
$form.TopMost = $true
$form.Width = 600
$form.Height = 600

#First name
$FirstName = New-Object System.Windows.Forms.Label
$FirstName.Text = "First Name"
$FirstName.AutoSize = $true
$FirstName.Width = 25
$FirstName.Height = 10
$FirstName.Location = New-Object System.Drawing.Point(7,26)
$FirstName.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($FirstName)

#First name text box
$FirstNameT = New-Object System.Windows.Forms.TextBox
$FirstNameT.Width = 100
$FirstNameT.Height = 20
$FirstNameT.Location = New-Object System.Drawing.Point(7,46)
$FirstNameT.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($FirstNameT)

#Last name
$LastName = New-Object System.Windows.Forms.Label
$LastName.Text = "Last Name"
$LastName.AutoSize = $true
$LastName.Width = 25
$LastName.Height = 10
$LastName.Location = New-Object System.Drawing.Point(126,26)
$LastName.Font = "Microsoft Sans Serif,10"
$form.Controls.add($Lastname)

#Last name text box
$lastNameT = New-Object System.windows.Forms.TextBox
$lastNameT.Width = 100
$lastNameT.Height = 20
$lastNameT.Location = New-Object System.drawing.point(126,46)
$lastNameT.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($lastNameT)

#Day
$Day = New-Object System.Windows.Forms.Label
$Day.Text = "Day"
$Day.AutoSize = $true
$Day.Width = 25
$Day.Height = 10
$Day.Location = New-Object System.Drawing.Point(256,26)
$Day.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($Day)

#Day text box
$DayT = New-Object System.Windows.Forms.TextBox
$DayT.Width = 50
$DayT.Height = 20
$DayT.Location = New-Object System.Drawing.Point(256,46)
$DayT.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($DayT)

#Month
$Month = New-Object System.Windows.Forms.Label
$Month.Text = "Month"
$Month.AutoSize = $true
$Month.Width = 25
$Month.Height = 10
$Month.Location = New-Object System.Drawing.Point(332,26)
$Month.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($Month)

#Month text box
$MonthT = New-Object System.Windows.Forms.TextBox
$MonthT.Width = 50
$MonthT.Height = 20
$MonthT.Location = New-Object System.Drawing.Point(332,46)
$MonthT.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($MonthT)

#Year
$Year = New-Object System.Windows.Forms.Label
$Year.Text = "Year"
$Year.AutoSize = $true
$Year.Width = 25
$Year.Height = 10
$Year.Location = New-Object System.Drawing.Point(408,26)
$Year.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($Year)
¨#Year text box
$YearT = New-Object System.Windows.Forms.TextBox
$YearT.Width = 50
$YearT.Height = 20
$YearT.Location = New-Object System.Drawing.Point(408,46)
$YearT.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($YearT)

#List box OU menu
$OUBox = New-Object System.Windows.Forms.ListBox
$OUBox.Text = "Organizational unit"
$OUBox.Width = 400
$OUBox.Height = 100
$OUBox.Location = New-Object system.drawing.point(7,100)
$OUBox.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($OUBox)

#import OU to "$OUBox" from AD/Brukere 
Get-ADOrganizationalUnit -filter * -SearchBase "ou=UsersOU,dc=Domain,dc=com" | ForEach-Object { [void] $OUBox.Items.Add($_) }

#List box security groups menu
$Group = New-Object System.Windows.Forms.ListBox
$Group.Text = "Security Group"
$Group.Width = 400
$Group.Height = 100
$Group.Location = New-Object system.drawing.point(7,220)
$Group.Font = "Microsoft Sans Serif,10"
$form.Controls.Add($Group)

#import Security Groups to "$Group" from AD/Groups
Get-ADGroup -filter * -SearchBase "ou=SecurityGroup,dc=Doamin,dc=com" | ForEach-Object { [void] $Group.Items.Add($_) }

#OK Button
$OKButton = New-Object System.Windows.Forms.Button 
$OKButton.Location = New-Object system.drawing.point (7,360)
$OKButton.Size = New-Object system.drawing.Size (75,23) 
$OKButton.Text = "Submit"
$OKButton.Add_Click({$x=$FirstNameT.Text;$form.Close()})
$form.Controls.Add($OKButton)

#Show form
[void]$form.ShowDialog()
$form.Dispose()

#Convert to string
$firstNameToString = $FirstNameT.ToString()
$LastNameToString = $lastNameT.ToString()
$dayToString = $DayT.ToString()
$monthToString = $MonthT.ToString()
$yearToString = $YearT.ToString()
$groupToString = $Group.ToString()
$ouToString = $OUBox.ToString()

#Remove unneeded values in strings
$firstNameString = $FirstNameT.Text -replace ".*: "
$lastNameString = $LastNameT.Text -replace ".*: "
$dayString = $DayT.Text -replace ".*: "
$monthString = $MonthT.Text -replace ".*: "
$yearString = $YearT.Text -replace ".*: "
$ouString = $OUBox.Text -replace ".*: "
$groupString = $Group.Text -replace ".*: "

#Creating usernames and other variables that is used
$Username = ($firstNameString.Substring(0,3) + $LastNameString.Substring(0,3) + $yearString.Substring(2,2))
$FullName = ($firstNameString + " " + $lastNameString)
$userPrincipalName = $Username + "@company.com".ToLower()

$numberOfUsers = (get-aduser -filter *).count
$employeeNumber = $numberOfUsers + 1

#Most for debuging but also to see that the script did what it was ment to do
write-host $ouString
Write-Host $groupString
write-host $Username
write-host $firstNameToString
write-host $yearToString
Write-Host $numberOfUsers
Write-Host $employeeNumber

#Creates the user based on the information generated form the variables on top
New-ADUser -Name $FullName -AccountPassword (ConvertTo-SecureString -AsPlainText "Passord123" -Force) -Enabled $true -Company "Company" -SamAccountName $Username -UserPrincipalName $userPrincipalName -Path $ouString -GivenName $FirstNameString -surname $LastNameString -EmailAddress $userPrincipalName -EmployeeNumber $employeeNumber -DisplayName $FullName

#Adds the user to the correct group also from variables
Add-ADGroupMember $groupString $Username