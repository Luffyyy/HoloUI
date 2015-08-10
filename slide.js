var img_count = 1;
var tot_imgs = 5;

function slider(x){
    var Image = document.getElementById('screen');
    img_count = img_count + x;
    Image.src = "img/screen1"+ img_count +".png";
}
