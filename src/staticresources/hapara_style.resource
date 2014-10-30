/*
Theme Name: Twenty Twelve
Theme URI: http://wordpress.org/extend/themes/twentytwelve
Author: the WordPress team
Author URI: http://wordpress.org/
Description: The 2012 theme for WordPress is a fully responsive theme that looks great on any device. Features include a front page template with its own widgets, an optional display font, styling for post formats on both index and single views, and an optional no-sidebar page template. Make it yours with a custom menu, header image, and background.
Version: 1.1
License: GNU General Public License v2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html
Tags: light, gray, white, one-column, two-columns, right-sidebar, flexible-width, custom-background, custom-header, custom-menu, editor-style, featured-images, flexible-header, full-width-template, microformats, post-formats, rtl-language-support, sticky-post, theme-options, translation-ready
Text Domain: twentytwelve

This theme, like WordPress, is licensed under the GPL.
Use it to make something cool, have fun, and share what you've learned with others.
*/

/* =Notes
--------------------------------------------------------------
This stylesheet uses rem values with a pixel fallback. The rem
values (and line heights) are calculated using two variables:

$rembase:     14;
$line-height: 24;

---------- Examples

* Use a pixel value with a rem fallback for font-size, padding, margins, etc.
	padding: 5px 0;
	padding: 0.357142857rem 0; (5 / $rembase)

* Set a font-size and then set a line-height based on the font-size
	font-size: 16px
	font-size: 1.142857143rem; (16 / $rembase)
	line-height: 1.5; ($line-height / 16)

---------- Vertical spacing

Vertical spacing between most elements should use 24px or 48px
to maintain vertical rhythm:

.my-new-div {
	margin: 24px 0;
	margin: 1.714285714rem 0; ( 24 / $rembase )
}

---------- Further reading

http://snook.ca/archives/html_and_css/font-size-with-rem
http://blog.typekit.com/2011/11/09/type-study-sizing-the-legible-letter/


/* =Reset
-------------------------------------------------------------- */

@charset "utf-8";
/* CSS Document */

body
{
	margin:0;
	font-family:Arial, Helvetica, sans-serif;
	color: #2C2C2C;
    font-family: Arial,Helvetica,sans-serif;
    font-size: 12px;
    line-height: 19px;
}

.line-bg
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/line-bg.jpg);
	background-repeat:repeat-x;
	height:5px;
}

.nav-links
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#2c2c2c;
	text-decoration:none;
	font-weight:bold;
}

.nav-links a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#2c2c2c;
	text-decoration:none;
	font-weight:bold;
	margin-left:27px;
	margin-right:27px;
}

.nav-links a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#b3b3b3;
	text-decoration:none;
	font-weight:bold;
	margin-left:27px;
	margin-right:27px;
}

.nav-links-active
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#535353 !important;
	text-decoration:none;
	font-weight:bold;
	margin-left:27px;
	margin-right:27px;
}


.box-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/box-top.jpg);
	background-repeat:no-repeat;
	background-position:top;
	height:100px;
	padding-top: 25px;
}

.box-bottom
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/box-bottom.jpg);
	background-repeat:no-repeat;
	background-position:top;
	width:904px;
	height:11px;
}

.box-bg
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/box-bg.jpg);
	background-repeat:repeat-y;
}

.iframeBox-bg
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/iframeBox-bg.png);
	background-repeat:no-repeat;
	width:478px;
	height:301px;
}

.txt-blue23
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:25px;
	color:#22c1e1;
}

.txt-purple46
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:46px;
	color:#2d2b7e;
	font-weight:bold;
	text-align:center;
	line-height:normal;
}


.head-gray25
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:25px;
	color:#595959;
	font-weight:bold;
	text-align:left;
}

.blueBox-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/blueBox-top.jpg);
	background-repeat:no-repeat;
	height:53px;
}

.purpleBox-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/purpleBox-top.jpg);
	background-repeat:no-repeat;
	height:53px;
}

.orangeBox-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/orangeBox-top.jpg);
	background-repeat:no-repeat;
	height:53px;
}

.greenBox-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/greenBox-top.jpg);
	background-repeat:no-repeat;
	height:53px;
}

.head-white22
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:22px;
	color:#FFF;
	font-weight:bold;
}

.bdy-txt
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#000;
	line-height:21px;
	text-decoration:none;
}

.bdy-txt a
{
	text-decoration:none;
}

.bdy-txt a:hover
{
	text-decoration:none;
}

.txt-13
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#000;
	line-height:21px;
	text-decoration:none;
}

.txt-13 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#00F;
	line-height:21px;
	text-decoration:none;
}

.txt-13 a:hover
{
	text-decoration:underline;
}

.copyright
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-align:left;
}

.footer-links, .footer-links a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:18px;
	color:#0f0c7e;
	text-decoration:none;
}

.footer-links a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:18px;
	color:#0f0c7e;
	text-decoration:none;
}

.txt-19
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:19px;
	color:#595959;
	text-decoration:none;
}

.txt-17
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:18px;
	color:#2c2c2c;
	font-style:italic;
	line-height:27px;
}

.txt12
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:none;
}

.txt12 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#00F;
	text-decoration:none;
}

.productsPage-bg
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/productsFrame-bg.png);
	background-repeat:no-repeat;
	width:450px;
	height:339px;
}

.shadow-bg
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/shadow-bg.jpg);
	background-repeat:no-repeat;
	width:337px;
	height:16px;
	background-position:bottom;
}

.list
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#000;
	text-decoration:none;
	margin:11px 0px 0px 15px;
	padding:0px;
}

.list li
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#000;
	line-height:21px;
	text-decoration:none;
	margin:0px 00px 3px 0px;
	padding:0px;
}

.pricingBlue-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/pricingBlue-top.jpg);
	background-repeat:repeat-x;
	height:72px;
}

.pricingPurple-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/pricingPurple-top.jpg);
	background-repeat:repeat-x;
	height:115px;
}

.pricingOrange-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/pricingOrange-top.jpg);
	background-repeat:repeat-x;
	height:115px;
}

.pricingGreen-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/pricingGreen-top.jpg);
	background-repeat:repeat-x;
	height:115px;
}

.txt-14-head
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	line-height:21px;
	font-weight:bold;
}

/*Ammar*/
.txt-14
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	/*line-height:16px;*/
}

.txt-14 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color: #00F;
	/*line-height:16px;*/
	text-decoration:none;
}

.txt-14 ul
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	margin:0px 0px 0px 15px;
	padding:0px;
}

.txt-14 ul li
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	margin:0px 00px 10px 0px;
	padding:0px;
}

.txt-14-02
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	line-height:24px;
}

.txt-14-02 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color: #00F;
	line-height:24px;
	text-decoration:none;
}

.txt-14-02 ul
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	margin:0px 0px 0px 15px;
	padding:0px;
}

.txt-14-02 ul li
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	margin:0px 00px 10px 0px;
	padding:0px;
}

.txt12-01
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:none;
}

.txt12-01 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color: #00F;
	text-decoration:none;
}

.txt13-01
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:13px;
	color:#000;
	line-height:15px;
	text-decoration:none;
}

.txt13-01 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:13px;
	color: #00F;
	line-height:15px;
	text-decoration:none;
}

.txt13p-01
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:13px;
	color:#000;
	line-height:17px;
	text-decoration:none;
}

.txt13p-01 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:13px;
	color: #00F;
	line-height:17px;
	text-decoration:none;
}


.txt-17-01
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:18px;
	color:#2c2c2c;
	line-height:17px;
}

.txt-17-01 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:18px;
	color: #00F;
	line-height:17px;
	text-decoration:none;
}

.txt-19-01
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:19px;
	color:#595959;
	text-decoration:none;
	line-height:25px;
}

.txt-19-01 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:19px;
	color:# 00F;
	text-decoration:none;
	line-height:25px;
}

.pHeading
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:14px;
	color:#2c2c2c;
	line-height:17px;
}

.head-pro
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:20px;
	color:#595959;
	font-weight:bold;
	text-align:left;
}

#btn:hover
{
	opacity:0.5;
	filter:alpha(opacity=50); /* For IE8 and earlier */
}

.entry-header
{
	display:none;
}

/*Theme css*/

/* =Comments
-------------------------------------------------------------- */

.comments-title {
	margin-bottom: 0px;
	margin-bottom: 0px;
	font-size: 16px;
	font-size: 1.142857143rem;
	line-height:0;
	font-weight: normal;
}
.comments-area article {
	margin: 24px 0;
	margin: 1.714285714rem 0;
}
.comments-area article header {
	margin:0px;
	overflow: hidden;
	position: relative;
}
.comments-area article header img {
	float: left;
	padding: 0;
	line-height: 0;
}
.comments-area article header cite,
.comments-area article header time {
	display: block;
	margin-left: 85px;
	margin-left: 6.071428571rem;
}
.comments-area article header cite {
	font-style: normal;
	font-size: 15px;
	font-size: 1.071428571rem;
	line-height: 1.42857143;
}
.comments-area article header time {
	line-height: 1.714285714;
	text-decoration: none;
	font-size: 12px;
	font-size: 0.857142857rem;
	color: #5e5e5e;
}
.comments-area article header a {
	text-decoration: none;
	color: #5e5e5e;
}
.comments-area article header a:hover {
	color: #21759b;
}
.comments-area article header cite a {
	color: #444;
}
.comments-area article header cite a:hover {
	text-decoration: underline;
}
.comments-area article header h4 {
	position: absolute;
	top: 0;
	right: 0;
	padding: 6px 12px;
	padding: 0.428571429rem 0.857142857rem;
	font-size: 12px;
	font-size: 0.857142857rem;
	font-weight: normal;
	color: #fff;
	background-color: #0088d0;
	background-repeat: repeat-x;
	background-image: -moz-linear-gradient(top, #009cee, #0088d0);
	background-image: -ms-linear-gradient(top, #009cee, #0088d0);
	background-image: -webkit-linear-gradient(top, #009cee, #0088d0);
	background-image: -o-linear-gradient(top, #009cee, #0088d0);
	background-image: linear-gradient(top, #009cee, #0088d0);
	border-radius: 3px;
	border: 1px solid #007cbd;
}
.comments-area li.bypostauthor cite span {
	position: absolute;
	margin-left: 5px;
	margin-left: 0.357142857rem;
	padding: 2px 5px;
	padding: 0.142857143rem 0.357142857rem;
	font-size: 10px;
	font-size: 0.714285714rem;
}
a.comment-reply-link,
a.comment-edit-link {
	color: #686868;
	font-size: 13px;
	font-size: 0.928571429rem;
	line-height: 1.846153846;
}
a.comment-reply-link:hover,
a.comment-edit-link:hover {
	color: #21759b;
}
.commentlist .pingback {
	line-height: 1.714285714;
	margin-bottom: 24px;
	margin-bottom: 1.714285714rem;
}

/* Comment form */
#respond {
	margin-top: 48px;
	margin-top: 0px;
}
#respond h3#reply-title {
	font-size: 16px;
	font-size: 1.142857143rem;
	line-height: 1.5;
}
#respond h3#reply-title #cancel-comment-reply-link {
	margin-left: 10px;
	margin-left: 0.714285714rem;
	font-weight: normal;
	font-size: 12px;
	font-size: 0.857142857rem;
}
#respond form {
	margin: 24px 0;
	margin: 1.714285714rem 0;
}
#respond form p {
	margin: 11px 0;
	margin: 0.785714286rem 0;
}
#respond form p.logged-in-as {
	margin-bottom: 24px;
	margin-bottom: 1.714285714rem;
}
#respond form label {
	display: block;
	line-height: 1.714285714;
}
#respond form input[type="text"],
#respond form textarea {
	-moz-box-sizing: border-box;
	box-sizing: border-box;
	font-size: 12px;
	font-size: 0.857142857rem;
	line-height: 1.714285714;
	padding: 10px;
	padding: 0.714285714rem;
	width: 100%;
}
#respond form p.form-allowed-tags {
	margin: 0;
	font-size: 12px;
	font-size: 0.857142857rem;
	line-height: 2;
	color: #5e5e5e;
}
.required {
	color: red;
}

#tb
{
	border:#000 3px solid;
}

#bor-bottom
{
	border-bottom:#000 thin solid;
}

.latest-head
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#241e4c;
	font-weight:bold;
	text-align:left;
}

.latest-txt
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:13px;
	color:#000;
	text-decoration:none;
}

.latest-txt a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:13px;
	color:#00F;
	text-decoration:underline;
}

label
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	line-height:24px;
}

span
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	line-height:24px;
}
div
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	line-height:24px;
}
p
{
 	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#2c2c2c;
	line-height:24px;
}

/*  Blog CSS */

.blogBox-top
{
	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/blogBox-top.jpg);
	background-repeat:no-repeat;
	background-position:top;
	height:100px;
}

.blogBox-bg
{

	background-image:url(http://hapara.com/wp-content/themes/twentytwelve/theme_images/blogBox-bg.jpg);
	background-repeat:repeat-y;
}

.entry-title, .entry-title a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:18px;
	color:#595959;
	text-decoration:none;
	margin-top:5px;
	margin-bottom:0px;
}

.entry-title a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:18px;
	color:#2c2c2c;
	text-decoration:none;
}

.entry-content
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#2c2c2c;
	text-decoration:none;
	line-height:19px;
}

.blog-12, .blog-12 a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:none;
}

.blog-12 a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:underline;
}

.more-link, .more-link a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:none;
}

.more-link a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:underline;
}

.entries-link, .entries-link a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#00f;
	text-decoration:none;
}

.entries-link a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:underline;
}

.blogTopics
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#2c2c2c;
	text-decoration:none;
	line-height:19px;
}

.blogTopics a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#333;
	text-decoration:none;
	line-height:19px;
	font-weight:bold;
}

.blogTopics a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#333;
	text-decoration:underline;
	line-height:19px;
}

.widget-title
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#241e4c;
	font-weight:bold;
	text-align:left;
}

.entry-meta, .entry-meta a
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:none;
}

.entry-meta a:hover
{
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
	color:#000;
	text-decoration:underline;
}


.green{
	color:green;
}

.red{
	color:red;
}

.blue{
	color:blue;
}
.grey{
	color:#999;
}




.blog-txt-italic
{
	width:96%;
	display:block;
	float:right;
	text-align:left;
	font-style:italic;
	clear:both;
	margin-bottom:25px;
	margin-left:35px;
	line-height:21px;
}


 .formLayout
    {
        padding: 10px;
        width: 100%;
    }
    
.formLayout label, input[type="text"]
    {
        display: block;
        width: 200px;
        float: left;
        margin-bottom: 10px;
    }
.formLayout textarea
	{
		 width: 400px;
		 height: 50px;
	}    
 
.formLayout label
    {
        text-align: right;
        padding-right: 20px;
    }
 
 br
    {
        clear: left;
    }
 sup
	{
		display:block;
		float:left;
		padding-right:1px;
	}