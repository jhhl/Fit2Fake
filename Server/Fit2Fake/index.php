<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta name="viewport" content="width=320">
<title>jhhl.net: iPhone : All The News That's Fit To Fake 1.0</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="shortcut icon" href="/favicon.ico">
<style TYPE="text/css">
//@import "/jhhl.css";

 table {
color:#000;
background:#efe;
font-size:18px;
font-family: Arial, Verdana, Helvetica,Sans-Serif;
}
body
{
font-family: Arial, Verdana, Helvetica,Sans-Serif;

}
p
{
margin-bottom:1em;
}
img
{
border: 2px solid black;
margin: 1em;
}
</style>
</head>

<body>
<?php
// write the referrer to a file date ("l dS of F Y h:i:s A")
$filename = 'f2fref.txt';
$somecontent = date ("Ymd H:i:s") . " -- " . $_SERVER["HTTP_REFERER"]." -- ".$_SERVER["HTTP_USER_AGENT"]." -- ".$_SERVER["REMOTE_ADDR"]."\n";

// Let's make sure the file exists and is writable first.
if (is_writable($filename)) {

    // In our example we're opening $filename in append mode.
    // The file pointer is at the bottom of the file hence 
    // that's where $somecontent will go when we fwrite() it.
    if (!$handle = fopen($filename, 'a')) {
         print "Cannot open file ($filename)";
         exit;
    }

    // Write $somecontent to our opened file.
    if (!fwrite($handle, $somecontent)) {
        print "Cannot write to file ($filename)";
        exit;
    }
    
  //  print "<!-- ($somecontent) is in  ($filename) -->";
    
    fclose($handle);
                                        
} else {
     print " <!-- The file $filename is not writable --> ";  
}


?>

<div align="center">
<table bgcolor="#EEEEEE" cellpadding="5" cellspacing="0" border="0" width="800">
<tr><td align="center"><span class="title"><a href="/"><img src="/images/icon32h.gif" alt="home"></a> j h h l . n e t <a href="/"><img src="/images/icon32h.gif" alt="home"></a></span><br>
</td></tr>
<tr><td>
<!-- blurb goes here -->


<center>
<table style="border:0px;" cellpadding="2">
<tr><td valign="top" align="center">
<img src="images/Icon-320.png" alt="Fit To Fake"  border="2" />
</td>
<td valign="top">
<h1>All The News That's Fit To Fake</h1>
  version 1.0
<br />
</td></tr></table>
</center>

<br>&nbsp;<br>
<p>
Fit To Fake uses crude AI to make new paragraphs out of a pool of exisiting ones. Fit To Fake can get sources of short stories from a number of providers.
</p>
<p>
<ul>
<li>Tap one of the section buttons, and it will display a set of paragraphs to be used in the pool of sources, and F2F will immediately start making up new sentences.</li>
<li>Tap a paragraph to add it to the pool of sentences that it uses to make up a new paragraph.</li>
<li>Tap the generated paragraph to generate a new one.</li>
</ul></p>
<p>Share these generated paragraph as text or as a png image to social media or other programs by using the 'SHARE' buttons.
</p>
<p>The pool can be cleared by tapping  the 'FORGET' button.
</p>
<p>The 'SPEAK' button toggles reading the paragraph with text to speech.
</p>
<p>Current data sources are built in texts, the New York Times API, and it's 'powered by NewsAPI.org'
</p>
<p>Look for more sources of text in the future!
</p>
</p>
<b>Fit To Fake</b> is by the author of 
<a href="/iPhone/">many other apps</a>  .
<br>&nbsp;<br>
   
<br />
<b>Support</b>
<br />&nbsp;<br />
 &bull; Questions? Write to fit2fake "at" jhhl.net, or go to the <a href="/contact.html">contact page</a><br />

&bull; Read about my iPhone development in this <a href ="/nucleus/InHope.php">blog</a>

<br />&nbsp;<br />
 
<p >&copy; 2019 <a href="http://www.jhhl.net/">Henry Lowengard</a></p>

</TD></TR>

 

<!-- short navbar goes here -->
<tr><td>

<table width="100%">
<tr><td width="50%">
<span class="navbar"><a href="../"><img src="/iPhone/apple-touch-icon-114x114-precomposed.png" alt=""> <br />jhhl's iPhone Apps</a></span>
</td><td>
<span class="navbar"><a href="/"><img src="/images/icon32h.gif" ALT="home"><br />Main jhhl.net website</a></span>
</td></tr></table>

</td></tr>
<!-- end nav bar -->
 
<TR><TD> <DIV ALIGN="RIGHT" CLASS="tiny">&copy; 2019 Henry Lowengard.</DIV></TD></TR>
</table>
</div>
</body>
</html>
