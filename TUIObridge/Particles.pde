
import java.util.Locale;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.flowfieldparticles.DwFlowFieldParticles;
import com.thomasdiewald.pixelflow.java.imageprocessing.DwFlowField;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.Merge;

import processing.core.*;
import processing.opengl.PGraphics2D;

int viewport_w = 1280;
int viewport_h = 720;
int viewport_x = 230;
int viewport_y = 0;

PGraphics2D pg_canvas;
PGraphics2D pg_obstacles;

DwPixelFlow context;

DwFlowFieldParticles particles;
DwFlowField ff_acc;

void setupParticles() {
  viewport_w = (int) min(viewport_w, displayWidth  * 0.9f);
  viewport_h = (int) min(viewport_h, displayHeight * 0.9f);
  //size(viewport_w, viewport_h, P2D);
  smooth(0);

  surface.setLocation(viewport_x-900, viewport_y);

  context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  particles = new DwFlowFieldParticles(context, 512 * 512);
  particles.param.col_A = new float[]{0.10f, 0.50f, 0.80f, 5};
  particles.param.col_B = new float[]{0.05f, 0.25f, 0.40f, 0};
  particles.param.shader_collision_mult = 0.2f;
  particles.param.steps = 1;
  particles.param.velocity_damping  = 0.995f;
  particles.param.size_display   = 10;
  particles.param.size_collision = 10;
  particles.param.size_cohesion  = 4;
  particles.param.mul_coh = 0.50f;
  particles.param.mul_col = 1.00f;
  particles.param.mul_obs = 2.00f;
  particles.resizeParticlesCount(10);

  pg_canvas = (PGraphics2D) createGraphics(width, height, P2D);
  pg_canvas.smooth(0);

  pg_obstacles = (PGraphics2D) createGraphics(width, height, P2D);
  pg_obstacles.smooth(8);
  // create gravity flow field
  PGraphics2D pg_gravity = (PGraphics2D) createGraphics(width, height, P2D);
  pg_gravity.smooth(0);
  pg_gravity.beginDraw();
  pg_gravity.background(0, 255, 0); // only green channel for gravity
  pg_gravity.endDraw();

  ff_acc = new DwFlowField(context);
  ff_acc.resize(width, height);
  Merge.TexMad ta = new Merge.TexMad(pg_gravity, -0.05f, 0);
  DwFilter.get(context).merge.apply(ff_acc.tex_vel, ta);
}


void updateScene() {

  int w = pg_obstacles.width;
  int h = pg_obstacles.height;
  float dim = 2* h/3f;

  pg_obstacles.beginDraw();
  pg_obstacles.clear();
  pg_obstacles.noStroke();
  pg_obstacles.blendMode(REPLACE);
  pg_obstacles.rectMode(CORNER);

  // border
  pg_obstacles.fill(0, 255);
  pg_obstacles.rect(0, 0, w, h);
  pg_obstacles.fill(0, 0);
  pg_obstacles.rect(10, 10, w-20, h-20);

  // animated obstacles
  pg_obstacles.rectMode(CENTER);
  pg_obstacles.pushMatrix();
  {
    float rot = frameCount / 180f;
    pg_obstacles.translate(w/2, h-dim/2);
    pg_obstacles.rotate(rot);
    pg_obstacles.fill(0, 255);
    pg_obstacles.rect(0, 0, dim, 20);
    pg_obstacles.rect(0, 0, 20, dim);
  }
  pg_obstacles.popMatrix();
  pg_obstacles.endDraw();
}



public void spawnParticles() {

  float px, py, vx, vy, radius;
  int count, vw, vh;

  vw = width;
  vh = height;

  count = 1;
  radius = 10;
  px = vw/2f;
  py = vh/4f;
  vx = 0;
  vy = 4;

  DwFlowFieldParticles.SpawnRadial sr = new DwFlowFieldParticles.SpawnRadial();
  sr.num(count);
  sr.dim(radius, radius);
  sr.pos(px, vh-1-py);
  sr.vel(vx, vy);
  particles.spawn(vw, vh, sr);

  if (mousePressed) {
    float pr = particles.getCollisionSize() * 0.5f;
    count = ceil(particles.getCount() * 0.01f);
    count = min(max(count, 1), 4000);  
    radius = ceil(sqrt(count * pr * pr));
    px = mouseX;
    py = mouseY;
    vx = (mouseX - pmouseX) * +5;
    vy = (mouseY - pmouseY) * -5;

    sr.num(count);
    sr.dim(radius, radius);
    sr.pos(px, vh-1-py);
    sr.vel(vx, vy);
    particles.spawn(vw, vh, sr);
  }
}
