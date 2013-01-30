
// $( function() {
//   var canvas = document.getElementById('canvas')
//   var context = canvas.getContext('2d');
//   var tileSize = 20;
//   var horizontalTileCount = ( canvas.width / tileSize ) + 2;
//   var verticalTileCount = (canvas.height / tileSize) + 2;
// 
//   window.addEventListener('resize', resizeCanvas, false);
//   
//   function resizeCanvas() {
//     // only redraw if it's bigger!
// 		var maxHeight = $(canvas).height(); //Math.max($(document).height(), window.innerHeight);
// 		var maxWidth  = Math.max($(document).width(), window.innerWidth);		
// 		
//     if (maxWidth > canvas.width || maxHeight > canvas.height) {
//           canvas.width = maxWidth;
//           canvas.height = maxHeight;
//           horizontalTileCount = ( canvas.width / tileSize ) + 2;
//           verticalTileCount = (canvas.height / tileSize) + 2;
// 
//           drawBackground(); 
//     };
//   }
//   
//   function drawBackground() {
//     for (var i = -0.5; i < horizontalTileCount; i++) {
//         for (var j = -0.5; j < verticalTileCount; j++) {
//           var colour = Math.floor(Math.random() * 10);
//           switch(colour) {
//               case 1 : context.fillStyle = "#f6e93f"; break;
//               case 2 : context.fillStyle = "#5dadf8"; break;
//               default: context.fillStyle = "#ffffff"; break;
//           }
//           context.fillRect(i * tileSize - 1,  j * tileSize - 1, tileSize - 2, tileSize - 2);
//         }
//     }
//     if (canvas.style.opacity == 0) {
//       $(canvas).animate({opacity: 0.5}, 0.5);
//     };
//   }
// 
//   function createBackgroundAnimations() {
//     setInterval(function() { 
//       var x = Math.floor(Math.random() * horizontalTileCount);
//       var y = Math.floor(Math.random() * verticalTileCount);
//       var colourInt = Math.floor(Math.random() * 3);
//       var colour;
//       switch(colourInt) {
//           case 1 : colour = "rgba(246, 233, 63, 0.2)"; break;
//           case 2 : colour = "rgba(93, 173, 248, 0.2)"; break;
//           default: colour = "rgba(255, 255, 255, 0.2"; break;
//       }
//       animateRectAtXYWithColour(x, y, colour, tileSize);
//     }, 150);
// 
//   }
// 
//   function animateRectAtXYWithColour(x, y, colour, size){
//     var tickCount = 0;
//     var xPosition = x * size - 1 - (size / 2);
//     var yPosition = y * size - 1 - (size / 2);
//     var timer = setInterval(function() { 
//       context.fillStyle = colour;
//       context.fillRect(xPosition, yPosition, size - 2, size - 2);
//       if (tickCount++ == 15) {
//           clearInterval(timer);
//       }
//     }, 100);
//   }
// 
//   resizeCanvas();
//   createBackgroundAnimations();
// });

Number.prototype.commaSeparated = function() {
    var n = this,
        t = ",",
        s = n < 0 ? "-" : "",
        i = parseInt(n = Math.abs(+n || 0)) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t);
};
