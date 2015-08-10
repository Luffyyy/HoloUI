var imgnum = 1;
var tot_imgs = 5;

function slider(x){
    var Image = document.getElementById('screen');
    imgnum = imgnum + x;
    if(imgnum > tot_imgs){
    imgnum = 1;
    }
    if(imgnum < tot_imgs){
    imgnum = tot_imgs;
    }
    Image.src = "img/screen" + imgnum + ".png";
}
