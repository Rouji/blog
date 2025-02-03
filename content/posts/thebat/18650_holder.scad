    //
    // units: mm
    //
    //Settings:
    bottom_thickness = 0.3; //thickness of the bottom holder part
    inside_diam = 18.7; //inside diameter of the cell holder
    hole_diam = 13; //diameter of the center hole
    height = 6; //total height of the holder
    wall = 0.84; // wall size, number should be slightly bigger than nozzle size
    resolution = 200; //best to be divisible by 4
    row = 4; //cells in row
    col = 5; //cells in column
    type = "hex"; // "square" or "hex" type of holder formation
     
    //End settings

    diameter = inside_diam + wall;
    rad=diameter/2;
    $fn= resolution;


module cell(){

    difference(){
        
        cylinder(h=bottom_thickness,d=inside_diam+(2*wall)); 
        cylinder(h=bottom_thickness,d=hole_diam);
        }
    translate([0,0,bottom_thickness]){ 
    difference(){
        cylinder(h=height-bottom_thickness,d=inside_diam+2*wall);
        cylinder(h=height-bottom_thickness,d=inside_diam);
                }
    }
}
module cell_inside(){
    union(){
    cylinder(h=bottom_thickness,d=hole_diam);
    translate([0,0,bottom_thickness])
        cylinder(h=height-bottom_thickness,d=inside_diam);
        }
}

module box(){       
    translate([-rad-wall/2,-rad-wall/2,0])
    cube([row*diameter+wall,col*diameter+wall,height]);    
}
 
module hex(){
    for (a=[0:row-1]){
    posx=diameter*a; 
        for (b=[0:col-1]){
            if (b%2==0){          
                posy=sqrt(diameter*diameter-rad*rad)*b; 
                translate([posx,posy,0]) cell();
                       }       
            else {
                posy=(sqrt(diameter*diameter-rad*rad)*b); 
                translate([posx+rad,posy,0]) cell();
                 }
         }   
    }
}
module square(){  
    for (a=[0:row-1]){
        posx=(inside_diam+wall)*a; 
        translate([posx,0,0]) cell();
          for (b=[0:col-1]){
             posy=(inside_diam+wall)*b; 
             translate([posx,posy,0]) cell();  
          }      
    } 
}
module square_inside(){  
    for (a=[0:row-1]){
        posx=(inside_diam+wall)*a; 
        translate([posx,0,0]) cell_inside();
          for (b=[0:col-1]){
             posy=(inside_diam+wall)*b; 
             translate([posx,posy,0]) cell_inside();  
          }      
    } 
}
if (type == "hex") {    
    hex();    
    }
    
if (type == "square") {
    square();      
    }

