var CurrentImg = 1;
var OldImg = 1
var Imgs = 3;
AutoSlide();
function AutoSlide()
{  
    Slide(1);       
    setTimeout("AutoSlide", 3000);   
}
function Slide(x)
{
    "use strict";
    OldImg = CurrentImg
    CurrentImg = CurrentImg + x;
    if(CurrentImg > Imgs){
        CurrentImg = 1;
    }
    if(CurrentImg < 1){
        CurrentImg = Imgs;
    }
    ImgHide();
}
    
function ImgHide()
{
    setTimeout("ImgShow()", 300);
}
function ImgShow()
{
    document.getElementsByClassName('slide-imgs')[OldImg - 1].style.left = "1000px";
    document.getElementsByClassName('slide-imgs')[OldImg - 1].style.display = "block";
    document.getElementsByClassName('slide-imgs')[CurrentImg - 1].style.display = "block";
    document.getElementsByClassName('slide-imgs')[CurrentImg - 1].style.left = "0px";
}
