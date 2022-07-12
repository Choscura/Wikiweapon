color("red")
//mandrel_segment(caliber=9, strands = 16, layer_height = 2.5, strand_diameter=1);

//difference(){
//	cylinder(r = 8, h=100);
mandrel(overall_height=300, layer_height =.25, caliber = 37, strands=64, strand_size=0.4, end_twist=60, throat_depth=20);
//}



module barrel(base_mandrel){
	difference(){
		cylinder(d=base_mandrel.caliber * 1.8, l=base_mandrel.overall_height);
		base_mandrel();
	}
}

 
module mandrel(overall_height, layer_height, caliber, strands, strand_size, end_twist, throat_depth){
	//keep your imperial vs metric specs straight! either do all thousandths of an inch, or do all mm!
	//this part is the derived specifications of the barrel from your human specs
	//barrel_layers = overall_height/layer_height;		//the number of layers in your barrel
	throat_layers = throat_depth/layer_height;
	//this next line figures out the radius of a circle that would be 90 degrees to the side wall of the barrel, with the top line of the barrel at a height of the circle corresponding to the angle of twist in the rifling at that point. this offset radius is used to calculate the twist of the rifling at every layer of the mandrel.
	radius_offset = overall_height*(sin(90)/sin(end_twist));
	last_angle=0;	
	for(a=[0: layer_height: overall_height]){
		translate([0, 0, a]){
			//this is the conditional rotation bit, starting with the throat segment where the layers are printed straight:
			if (a <= throat_depth){
				mandrel_segment(caliber, strands, layer_height, strand_size);
				}
			//when you break above the point of the throat depth, then the sections are rotated according to their height above the throat depth, squared, as the side on a triangle where the hypotenuse is the radius_offset we calculated above. We solve for the angle of that triangle, at the height of the layer we are calculating for above the throat depth, and we don't care about the third line, the base of the triangle.
			else if (a>= throat_depth){
				rotator_height = (a - throat_depth);
				rotation_angle = asin((rotator_height * sin(90))/radius_offset);
				//this next section is a hack fuckup, where I figured out how to describe the angle of increase I wanted to add to the rifling, managed to specify that, but not to specify the original angle that the rifling needs to be at for this to increase, and so my subsequent fucking with it led me to take that angle of increase, multiply it by itself in the step before, which got TOO much twist, and to divide that up by 24, as a picked-from-air number that seems to just about correlate to the angle of twist I intuitively want to see.  OBVIOUSLY, I'm not going to stop at this point, but this is what it is now.
				rotate([0,0,((rotation_angle*last_angle)/24)]){
					mandrel_segment(caliber, strands, layer_height, strand_size);}	
				last_angle = rotation_angle;	
			};
		};
	}
}
	
module mandrel_segment(caliber, strands, layer_height, strand_diameter){
	difference(){
		cylinder(r=caliber/2, h=layer_height, center=true);
		make_ring_of(radius = (caliber/2) - (strand_diameter/2), count= strands)
			cylinder(r =strand_diameter, h = layer_height, center=true);}
	}
    

    
module make_ring_of(radius,count)
{
    for (a = [0 : count - 1]) {
        angle = a * 360 / count;
        translate(radius * [sin(angle), -cos(angle), 0])
            rotate([0, 0, angle])
                children();
    }
}//*/