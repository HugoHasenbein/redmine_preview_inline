# redmine_preview_inline

Plugin for Redmine. Show attachments inline 

![Animated GIF that represents a quick overview](/doc/Overview.gif)

### Use case(s)

* View contents of an attachment file inline

### Install

1. go to plugins folder

`git clone https://github.com/HugoHasenbein/redmine_preview_inline.git`

3. restart server f.i.  

`sudo /etc/init.d/apache2 restart`

### Uninstall

1. go to plugins folder

`rm -r redmine_preview_inline`

2. restart server f.i. 

`sudo /etc/init.d/apache2 restart`

### Use

* Go to Administration->Plugins->Redmine Preview Inline and choose embed method (if browser compatibilty issues occur) and preview size
* On Issue show page click on the magnifying glass next to an attachment link and view its contents inline

**Have fun!**

### Localisations


* 1.0.1 
  - English
  - German
* 1.0.0 
  - no localizable strings present in plugin

### Change-Log* 

**1.0.2** added support for full-width inline view for thumbnail links 

**1.0.1** added inline view link for thumbnail links  

**1.0.0** running on Redmine 3.4.6