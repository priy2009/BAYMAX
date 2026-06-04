// ==============================================================================
// FILE: ai_pet_head.scad
// DESCRIPTION: 3D printable Head Assembly for an AI Pet
// BASED ON: Hand-drawn sketch inspiration (Rounded head, Rectangular eyes)
// OPTIMIZATION: FDM 3D printing (supports needed for internal structures)
// MATERIALS: PLA/PETG
// ==============================================================================

// --- GLOBAL PARAMETERS (Adjustable) -------------------------------------------
$fn = 64; // Smoothness of circles/curves

// Component Dimensions (Include tolerance)
tol = 0.3; // General FDM print tolerance

// Original dimensions kept to maintain overall head scale
oled_w = 27 + tol; 
oled_h = 27 + tol; 
oled_d = 5;        
speaker_dia = 40 + tol;
speaker_d = 15;

// General Design Parameters
wall_thickness = 3.0; // Thick walls for robustness
corner_radius = 8;    // For the rounded head silhouette

// --- MAIN ASSEMBLY CALCULATION ------------------------------------------------
head_w = max(speaker_dia + wall_thickness * 4, oled_w + 30); 
head_h = max(oled_h + 30, speaker_dia + 20); 
head_d = speaker_d + oled_d + 30; 

// --- MAIN EXECUTION -----------------------------------------------------------
// Generate the cleanly modified head assembly
difference() {
    main_head_volume();
    internal_hollow();
    ventilation_grille();
    display_and_cam_cutout();
}

// ==============================================================================
// MODULE DEFINITIONS
// ==============================================================================

// 1. MAIN SHELL GEOMETRY (Solid volume with rounded corners)
module main_head_volume() {
    hull() {
        translate([corner_radius, corner_radius, corner_radius]) 
            sphere(corner_radius);
        translate([head_w - corner_radius, corner_radius, corner_radius]) 
            sphere(corner_radius);
        translate([corner_radius, head_h - corner_radius, corner_radius]) 
            sphere(corner_radius);
        translate([head_w - corner_radius, head_h - corner_radius, corner_radius]) 
            sphere(corner_radius);
        
        translate([corner_radius, corner_radius, head_d - corner_radius]) 
            sphere(corner_radius);
        translate([head_w - corner_radius, corner_radius, head_d - corner_radius]) 
            sphere(corner_radius);
        translate([corner_radius, head_h - corner_radius, head_d - corner_radius]) 
            sphere(corner_radius);
        translate([head_w - corner_radius, head_h - corner_radius, head_d - corner_radius]) 
            sphere(corner_radius);
    }
}

// 2. INTERNAL HOLLOW (Space for components)
module internal_hollow() {
    translate([wall_thickness, wall_thickness, -1]) 
        scale([ (head_w - wall_thickness * 2)/head_w, 
                 (head_h - wall_thickness * 2)/head_h, 
                 (head_d + 1)/head_d ])
        main_head_volume();
}

// 3. NORMAL SPEAKER GRILLE (Left face, X = 0)
module ventilation_grille() {
    // Standard circular cluster of 3mm holes
    for(dy=[-15:5:15]) {
        for(dz=[-15:5:15]) {
            if (dy*dy + dz*dz <= 200) { // Keeps the pattern in a circle
                translate([-1, head_h/2 + dy, head_d/2 + dz]) 
                rotate([0, 90, 0])
                cylinder(h=wall_thickness + 2, d=3);
            }
        }
    }
}

// 4. DISPLAY & ESP32 CAM CUTOUTS (Right face, X = head_w)
module display_and_cam_cutout() {
    // Calculate square side for a 0.96" (24.384mm) diagonal
    // Side = Diagonal / sqrt(2) = 24.384 / 1.4142 = 17.24mm
    sq_side = 17.24;
    
    // Centered Square Display Cutout
    translate([head_w - wall_thickness - 1, head_h/2 - sq_side/2, head_d/2 - sq_side/2])
        cube([wall_thickness + 2, sq_side, sq_side]);
        
    // ESP32 Cam Cutout (Small 10x10mm square positioned just above the display)
    cam_size = 10;
    offset_z = 5; // Gap between the display and the camera hole
    translate([head_w - wall_thickness - 1, head_h/2 - cam_size/2, head_d/2 + sq_side/2 + offset_z])
        cube([wall_thickness + 2, cam_size, cam_size]);
}