package com.chakalia.racing;

import android.app.Activity;
import android.os.Bundle;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.opengl.GLSurfaceView;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.view.Gravity;
import android.view.MotionEvent;
import android.widget.*;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import java.nio.*;
import java.util.*;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class MainActivity extends Activity {
    private SensorManager sensors; private Sensor accelerometer; private RaceSurface race;
    private boolean tiltEnabled=false; private TextView scoreView, modeView;
    private int dp(float v){return (int)(v*getResources().getDisplayMetrics().density+.5f);}
    private GradientDrawable panel(int c){GradientDrawable d=new GradientDrawable();d.setColor(c);d.setCornerRadius(dp(15));d.setStroke(dp(1),0xFFFFC247);return d;}
    private TextView text(String s,int size,int color){TextView t=new TextView(this);t.setText(s);t.setTextSize(size);t.setTextColor(color);t.setGravity(Gravity.CENTER);t.setTypeface(Typeface.DEFAULT,Typeface.BOLD);return t;}
    private Button button(String s){Button b=new Button(this);b.setText(s);b.setTextSize(14);b.setAllCaps(false);b.setTextColor(Color.WHITE);b.setTypeface(Typeface.DEFAULT,Typeface.BOLD);b.setBackground(panel(0xFF192F50));return b;}
    @Override public void onCreate(Bundle b){super.onCreate(b);getWindow().setFlags(1024,1024);sensors=(SensorManager)getSystemService(SENSOR_SERVICE);accelerometer=sensors.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);showMenu();}
    private void showMenu(){LinearLayout p=new LinearLayout(this);p.setOrientation(1);p.setGravity(Gravity.CENTER);p.setPadding(dp(18),dp(10),dp(18),dp(10));p.setBackgroundColor(0xFF071022);p.addView(text("🏁 CHAKALIA RACING",32,Color.WHITE));p.addView(text("3D ARCADE • DRIVE • COLLECT • WIN",14,0xFFFFC247));TextView choose=text("Choose your race",18,Color.WHITE);LinearLayout.LayoutParams cp=new LinearLayout.LayoutParams(-1,dp(55));cp.topMargin=dp(12);p.addView(choose,cp);Button career=button("🏆  CAREER MODE");Button endless=button("♾  ENDLESS MODE");for(Button b:new Button[]{career,endless}){LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(dp(300),dp(54));lp.topMargin=dp(8);p.addView(b,lp);}career.setOnClickListener(v->startRace(true));endless.setOnClickListener(v->startRace(false));setContentView(p);}
    private void startRace(boolean career){FrameLayout frame=new FrameLayout(this);race=new RaceSurface(this,career);frame.addView(race);LinearLayout top=new LinearLayout(this);top.setPadding(dp(10),dp(3),dp(10),dp(3));top.setGravity(Gravity.CENTER_VERTICAL);top.setBackgroundColor(0x99071122);scoreView=text("SCORE 0  •  COINS 0",14,Color.WHITE);modeView=text(career?"CAREER • LEVEL 1":"ENDLESS",14,0xFFFFC247);top.addView(scoreView,new LinearLayout.LayoutParams(0,dp(38),1));top.addView(modeView);frame.addView(top,new FrameLayout.LayoutParams(-1,-2,Gravity.TOP));LinearLayout row=new LinearLayout(this);row.setGravity(Gravity.CENTER_VERTICAL);row.setPadding(dp(5),0,dp(5),dp(5));addControl(row,"◀",0,52);addControl(row,"▶",1,52);row.addView(new Space(this),new LinearLayout.LayoutParams(0,1,1));addControl(row,"BRAKE",2,68);addControl(row,"GAS",3,68);addControl(row,"NITRO",4,72);Button tilt=button("TILT OFF");row.addView(tilt,new LinearLayout.LayoutParams(dp(78),dp(46)));tilt.setOnClickListener(v->{tiltEnabled=!tiltEnabled;tilt.setText(tiltEnabled?"TILT ON":"TILT OFF");});Button pause=button("Ⅱ");row.addView(pause,new LinearLayout.LayoutParams(dp(48),dp(46)));pause.setOnClickListener(v->{race.renderer.paused=!race.renderer.paused;pause.setText(race.renderer.paused?"▶":"Ⅱ");});Button menu=button("MENU");row.addView(menu,new LinearLayout.LayoutParams(dp(60),dp(46)));menu.setOnClickListener(v->showMenu());frame.addView(row,new FrameLayout.LayoutParams(-1,dp(60),Gravity.BOTTOM));setContentView(frame);race.renderer.hud=(s,c,l)->runOnUiThread(()->{if(scoreView!=null)scoreView.setText("SCORE "+s+"  •  COINS "+c);if(modeView!=null)modeView.setText(career?"CAREER • LEVEL "+l:"ENDLESS");});}
    private void addControl(LinearLayout row,String label,int type,int width){Button b=button(label);LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(dp(width),dp(46));p.setMargins(dp(2),0,dp(2),0);row.addView(b,p);b.setOnTouchListener((v,e)->{boolean down=e.getAction()==MotionEvent.ACTION_DOWN||e.getAction()==MotionEvent.ACTION_MOVE;race.renderer.control(type,down);return true;});}
    @Override protected void onResume(){super.onResume();if(sensors!=null&&accelerometer!=null)sensors.registerListener(sensorListener,accelerometer,SensorManager.SENSOR_DELAY_GAME);if(race!=null)race.onResume();}
    @Override protected void onPause(){if(sensors!=null)sensors.unregisterListener(sensorListener);if(race!=null)race.onPause();super.onPause();}
    private final SensorEventListener sensorListener=new SensorEventListener(){public void onSensorChanged(SensorEvent e){if(tiltEnabled&&race!=null)race.renderer.tilt=Math.max(-1,Math.min(1,e.values[0]/4f));}public void onAccuracyChanged(Sensor s,int a){}};

    static class RaceSurface extends GLSurfaceView {final WorldRenderer renderer;RaceSurface(Context c,boolean career){super(c);setEGLContextClientVersion(2);renderer=new WorldRenderer(career);setRenderer(renderer);setRenderMode(GLSurfaceView.RENDERMODE_CONTINUOUSLY);}}
    interface Hud {void update(int score,int coins,int level);}
    static class WorldRenderer implements GLSurfaceView.Renderer {
        final boolean career; Hud hud; volatile boolean paused=false,brake=false,gas=false,nitro=false;volatile float steer=0,tilt=0;
        int program,aPos,uMvp,uColor;FloatBuffer cube;float[] proj=new float[16],view=new float[16],model=new float[16],mvp=new float[16];long last=0;
        float carX=0,roadOffset=0,speed=.65f,coinClock=0,trafficClock=0;int score=0,coins=0,level=1;Random random=new Random();ArrayList<Actor> actors=new ArrayList<>();
        WorldRenderer(boolean c){career=c;}
        void control(int t,boolean on){if(t==0)steer=on?-1:(steer<0?0:steer);if(t==1)steer=on?1:(steer>0?0:steer);if(t==2)brake=on;if(t==3)gas=on;if(t==4)nitro=on;}
        public void onSurfaceCreated(GL10 gl,EGLConfig cfg){GLES20.glClearColor(.025f,.05f,.10f,1);GLES20.glEnable(GLES20.GL_DEPTH_TEST);String vs="attribute vec3 aPosition; uniform mat4 uMVP; void main(){gl_Position=uMVP*vec4(aPosition,1.0);}";String fs="precision mediump float; uniform vec4 uColor; void main(){gl_FragColor=uColor;}";int v=shader(GLES20.GL_VERTEX_SHADER,vs),f=shader(GLES20.GL_FRAGMENT_SHADER,fs);program=GLES20.glCreateProgram();GLES20.glAttachShader(program,v);GLES20.glAttachShader(program,f);GLES20.glLinkProgram(program);aPos=GLES20.glGetAttribLocation(program,"aPosition");uMvp=GLES20.glGetUniformLocation(program,"uMVP");uColor=GLES20.glGetUniformLocation(program,"uColor");float[] a={-.5f,-.5f,.5f,.5f,-.5f,.5f,.5f,.5f,.5f,-.5f,-.5f,.5f,.5f,.5f,.5f,-.5f,.5f,.5f,-.5f,-.5f,-.5f,-.5f,.5f,-.5f,.5f,.5f,-.5f,-.5f,-.5f,-.5f,.5f,.5f,-.5f,.5f,-.5f,-.5f,-.5f,.5f,-.5f,-.5f,.5f,.5f,.5f,-.5f,.5f,-.5f,.5f,.5f,.5f,.5f,.5f,-.5f,-.5f,-.5f,.5f,-.5f,-.5f,.5f,-.5f,.5f,-.5f,-.5f,-.5f,.5f,-.5f,.5f,-.5f,-.5f,.5f,.5f,-.5f,.5f,.5f,.5f,.5f,-.5f,.5f,.5f,.5f,.5f,-.5f,.5f,-.5f,-.5f,-.5f,-.5f,-.5f,.5f,-.5f,.5f,.5f,-.5f,-.5f,-.5f,-.5f,.5f,.5f,-.5f,.5f,-.5f};cube=ByteBuffer.allocateDirect(a.length*4).order(ByteOrder.nativeOrder()).asFloatBuffer();cube.put(a).position(0);}
        int shader(int type,String src){int s=GLES20.glCreateShader(type);GLES20.glShaderSource(s,src);GLES20.glCompileShader(s);return s;}
        public void onSurfaceChanged(GL10 gl,int w,int h){GLES20.glViewport(0,0,w,h);Matrix.perspectiveM(proj,0,58,(float)w/Math.max(1,h),.1f,100);}
        public void onDrawFrame(GL10 gl){long now=System.nanoTime();float dt=last==0?.016f:Math.min(.05f,(now-last)/1e9f);last=now;if(!paused)update(dt);GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT|GLES20.GL_DEPTH_BUFFER_BIT);GLES20.glUseProgram(program);Matrix.setLookAtM(view,0,0,5.2f,9.5f,0,0,0,0,1,0);box(0,-.25f,-7,4.4f,.3f,35,.13f,.15f,.19f);box(-5,-.4f,-7,6,.2f,36,.04f,.33f,.15f);box(5,-.4f,-7,6,.2f,36,.04f,.33f,.15f);box(-2.18f,-.02f,-7,.12f,.05f,35,.95f,.95f,.95f);box(2.18f,-.02f,-7,.12f,.05f,35,.95f,.95f,.95f);for(int i=0;i<12;i++){float z=-17+(i*3.2f+roadOffset)%32;box(0,0,z,.07f,.04f,1.45f,1,.78f,.2f);}for(int i=0;i<10;i++){float z=-22+(i*4.4f+roadOffset)%42;float h1=1.4f+(i%3)*.48f,h2=1.7f+((i+1)%3)*.42f;box(-4.35f,h1/2f,z,1.25f,h1,2.0f,.12f+(i%2)*.05f,.19f,.29f);box(4.35f,h2/2f,z-1.3f,1.3f,h2,2.2f,.22f,.17f+(i%2)*.04f,.13f);for(int w=0;w<3;w++){box(-4.35f+(w-1)*.32f,h1*.62f,z+1.01f,.13f,.18f,.025f,.72f,.83f,.88f);box(4.35f+(w-1)*.32f,h2*.62f,z-.19f,.13f,.18f,.025f,.72f,.83f,.88f);}box(-2.95f,.75f,z,.08f,1.5f,.08f,.18f,.18f,.2f);box(-2.95f,1.52f,z,.35f,.08f,.35f,1,.82f,.42f);box(2.95f,.75f,z-1.2f,.08f,1.5f,.08f,.18f,.18f,.2f);box(2.95f,1.52f,z-1.2f,.35f,.08f,.35f,1,.82f,.42f);}for(Actor a:actors){float z=4.4f-a.z;if(a.coin)box(a.x,.5f,z,.32f,.32f,.13f,1,.72f,.02f);else drawCar(a.x,z,.88f,.12f,.07f,false);}drawCar(carX,3.2f,.9f,.08f,.08f,true);}
        void update(float dt){float s=Math.max(-1,Math.min(1,steer+tilt*.75f));carX=Math.max(-1.65f,Math.min(1.65f,carX+s*dt*3));if(gas)speed=Math.min(1.25f,speed+dt*.55f);else speed=Math.max(.48f,speed-dt*.06f);if(brake)speed=Math.max(.22f,speed-dt*.95f);if(nitro)speed=Math.min(1.7f,speed+dt*1.1f);roadOffset=(roadOffset+dt*speed*10)%3.2f;score+=(int)(dt*speed*25);coinClock+=dt;trafficClock+=dt;if(coinClock>2.1f){coinClock=0;actors.add(new Actor(lane(),-2,true));}if(trafficClock>Math.max(.8f,2-speed*.5f)){trafficClock=0;actors.add(new Actor(lane(),-2,false));}Iterator<Actor> it=actors.iterator();while(it.hasNext()){Actor a=it.next();a.z+=dt*speed*5.2f;if(a.z>7.4f){it.remove();continue;}if(a.z>5.8f&&a.z<6.6f&&Math.abs(a.x-carX)<.62f){if(a.coin){coins++;it.remove();}else{speed=.28f;score=Math.max(0,score-80);a.z=8;}}}if(career)level=1+score/700;if(hud!=null)hud.update(score,coins,level);}
        float lane(){return new float[]{-1.35f,0,1.35f}[random.nextInt(3)];}
        void drawCar(float x,float z,float r,float g,float b,boolean player){
            // Layered low-poly vehicle body: chassis, sculpted bonnet, cabin, glass, bumpers and wheels.
            box(x,.19f,z,.78f,.30f,1.28f,r,g,b);
            box(x,.30f,z+.43f,.73f,.18f,.42f,r*.92f,g*.92f,b*.92f);
            box(x,.31f,z-.48f,.73f,.17f,.32f,r*.82f,g*.82f,b*.82f);
            box(x,.48f,z-.13f,.52f,.34f,.62f,.10f,.16f,.22f);
            box(x,.50f,z-.13f,.46f,.27f,.55f,.20f,.34f,.42f);
            box(x-.27f,.47f,z-.13f,.035f,.28f,.57f,r*.75f,g*.75f,b*.75f);
            box(x+.27f,.47f,z-.13f,.035f,.28f,.57f,r*.75f,g*.75f,b*.75f);
            box(x,.65f,z-.13f,.49f,.035f,.57f,r*.72f,g*.72f,b*.72f);
            for(float wx:new float[]{-.39f,.39f})for(float wz:new float[]{-.39f,.39f}){
                box(x+wx,.12f,z+wz,.16f,.24f,.29f,.025f,.028f,.035f);
                box(x+wx,.12f,z+wz+.015f,.17f,.11f,.18f,.20f,.21f,.23f);
            }
            box(x-.25f,.27f,z+.66f,.16f,.09f,.035f,1,.88f,.62f);box(x+.25f,.27f,z+.66f,.16f,.09f,.035f,1,.88f,.62f);
            box(x-.25f,.27f,z-.66f,.16f,.09f,.035f,.95f,.06f,.035f);box(x+.25f,.27f,z-.66f,.16f,.09f,.035f,.95f,.06f,.035f);
            box(x,.16f,z+.68f,.64f,.10f,.12f,.16f,.17f,.19f);box(x,.16f,z-.68f,.64f,.10f,.12f,.16f,.17f,.19f);
            if(player){box(x-.22f,.26f,z+.72f,.10f,.055f,.025f,1,.12f,.04f);box(x+.22f,.26f,z+.72f,.10f,.055f,.025f,1,.12f,.04f);}
        }
        void box(float x,float y,float z,float sx,float sy,float sz,float r,float g,float b){Matrix.setIdentityM(model,0);Matrix.translateM(model,0,x,y,z);Matrix.scaleM(model,0,sx,sy,sz);Matrix.multiplyMM(mvp,0,view,0,model,0);Matrix.multiplyMM(mvp,0,proj,0,mvp,0);GLES20.glUniformMatrix4fv(uMvp,1,false,mvp,0);GLES20.glUniform4f(uColor,r,g,b,1);cube.position(0);GLES20.glEnableVertexAttribArray(aPos);GLES20.glVertexAttribPointer(aPos,3,GLES20.GL_FLOAT,false,0,cube);GLES20.glDrawArrays(GLES20.GL_TRIANGLES,0,36);GLES20.glDisableVertexAttribArray(aPos);}
        static class Actor{float x,z;boolean coin;Actor(float x,float z,boolean c){this.x=x;this.z=z;coin=c;}}
    }
}
