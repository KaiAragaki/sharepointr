# sharepointr <img src='man/figures/logo.png' align="right" height="139" />
Get and Push Files to SharePoint

# Who is this for?
People who use R and SharePoint (or might want to use SharePoint)

# How do I use it?

## Setup

First, install it from GitHub:

```
# install.packages("devtools")
devtools::install_github("kaiaragaki/sharepointr")
```

**Important:** Add a new column to your SharePoint document library by clicking "Add column" then "Single line of text". Name the column "source_code" (no caps, underscore).

Ensure you have proper permissions in the SharePoint. Making yourself a 'member' of the SharePoint if you aren't already is a good option.

## Quickstart

First, generate a token for yourself. This will give you permission to access the files that you should have access to.

```
library(sharepointr)
token <- sharepoint_token()
```
This will trigger an in browser authentication (which may require no intervention if you're already logged in to your account).


**To download a file:**

Go to your SharePoint and find the file you want to download, then right click. Select 'Details' from the drop-down box.

In the resultant right-hand panel, click "more details" (very bottom of panel).

Click the 'two sheets of paper' icon next to 'Path'.

Go back to R:

```
file_path <- sharepoint_get("https://mycompany.sharepoint.com/sites/my-site/Shared%20Documents/path/to/my/file.txt, 
                             token = token)
```

This `file_path` object is (as you might have guessed) a path to your now-downloaded file, which rests in a temporary directory. This file can now be read in with your favorite reading function.

**To upload a file:**

Go to your SharePoint and find the **directory** you want to upload into, and click the (i) button in the upper right-hand corner. **Note:** make sure you do not have any file selected when you do this - you want the directory path, not a file-in-the-directory path!

Like downloading a file, get the file path as before.

Back in R:

```
sharepoint_put(file = "./path/of/file/to/be/uploaded.txt", 
               dest_path = "https://mycompany.sharepoint.com/sites/my-site/Shared%20Documents/path/to/my/directory/",
               token = token,
               overwrite = F,
               file_name = "new_file_name.txt")
```

# What does `sharepointr` do?
`sharepointr` gives a simple way to download files from SharePoint (perhaps into a temporary folder that can be deleted after the R session closes). It also allows you to upload files to the SharePoint, automatically attaching the script from which the file came in a column on SharePoint named "source_code". 

# Why does it exist?
In brief: Security, collaboration, data unification, and 'narrative data'

## Security
SharePoint is HIPAA compliant, GitHub repositories are not

## Collaboration
Oftentimes many important figures and intermediate data are stored on GitHub, but only a small subset are presented (and a smaller subset still uploaded to a central repository that coders and non-coders alike regularly access). Your collegues may want to refer back to those data and figures, or may want to see the 'supplemental' figures you produced - not just the figures you presented. `sharepointr` seeks to make sharing data part of your workflow (and relatively painless) rather than being an addition to your workflow.

## Data Unification
A common strategy to figures and data is to take the file, copy it, and put it on (for example) SharePoint. This has several issues: It is an extra step that can sometimes be neglected (and inconsistency is often more frustrating than not at all), there are now twice as many files that exist in the 'file-ome' (the last thing we need is more clutter) and if one file gets updated, the other is left the same. `sharepointr` uploads the figure/dataset directly to SharePoint and can be updated each time the script is run (provided `overwrite = T`). Provided you write figures and datasets to a temporary folder before uploading them to SharePoint, they needn't even exist on your personal machine for longer than your R session is active.

## Narrative Data
Typically a figure tells fairly little about where it came from. Even the best annotated figure usually only talks about the raw dataset used to produce it, and none of the processing steps inbetween. While one of R's central goals is to allow for reproducibility, figure production is often 'out of its hands': the figure is completely divorced from the script used to generate it. `sharepointr` seeks to fix this by automatically including the script from which the figure or dataset came in a SharePoint column named 'source_code'.

# When?
Now.

# Limitations/Roadmap
* Currently only works with SharePoint, not with OneDrive. Support for OneDrive can likely be added in v1.1
* Pointr currently only allows for a maximum file size of 60MB. Larger file upload sizes are hopefully going to be added in v1.2
* User must manually create a source_code file if one does not exist. This is a limitation of the Microsoft Graph API - until they add support for this, this is the only option.
