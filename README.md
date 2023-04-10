# JCPR
JumpCloud Password Rotation

## Release Notes

### Version 0.1.0.0
Initial module creation

## Instructions

### Installation
Install-Module JCPR

### Initial Setup
* Make sure the password for the user already exists in Hudu
* Run Start-JcprApiConnections without the -Silent switch to allow the GUI to prompt for API info and store it in the Windows Credential Manager
* A JumpCloud agent must be installed on the computer running the password rotation script

### Automating Password Rotation
Run Start-JcprApiConnections with the -Silent switch first, followed by the Invoke-JcPasswordRotation -Email.
Example 1:
```
Start-JcprApiConnections -Silent
Invoke-JcPasswordRotation -Email 'testuser@domain.com'
```
Example 2:
```
$EmailList = @(
    test1@domain.com,
    test2@domain.com,
    test3@domain.com
)
Start-JcprApiConnections -Silent
$EmailList | ForEach-Object {
    Invoke-JcPasswordRotation -Email $_
}
```
