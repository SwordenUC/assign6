final int GAME_START = 0;
final int GAME_PLAYING = 1;
final int GAME_WIN = 2;
final int GAME_LOSE = 3;
int gameState = 0;
int fighterW = 51;
int fighterH = 51;
float treasureW = 41;
float treasureH = 41;
int shootW = 31;
int shootH = 27;
float bg1X;
float bg2X;
PImage start1 ;
PImage start2 ;
PImage bg1;
PImage bg2;
PImage end1 ;
PImage end2 ;
// enemy max count
final int enemyAmount = 8 ;

Enemy[] enemyArray = new Enemy[enemyAmount] ;

// enemy states
final int E_LINE = 0    ;
final int E_SLASH = 1   ; 
final int E_DIAMOND = 2 ;
final int E_BOSS = 3    ;

// enemy state
int enemyState ;

// FlameManager 
FlameManager flameManager ; 
final int yourFrameRate = 60 ;
Fighter fighter ; 
Treasure treasure;
HPBar hpBar; 
Bullet bullet; 

// shared images ; 
PImage enemyImg ;

//------------





void setup () {
  size(640, 480);
  bg1X = 0;
  bg2X = width;
  end1 = loadImage("img/end1.png");
  end2 = loadImage("img/end2.png");
  start1 = loadImage("img/start1.png");
  start2 = loadImage("img/start2.png");
  bg1 = loadImage("img/bg1.png");
  bg2 = loadImage("img/bg2.png");
  enemyImg = loadImage("img/enemy.png");
  bullet = new Bullet();
  fighter      = new Fighter ();
  flameManager = new FlameManager( 60 / 5 ) ; // this means update 5 images in 1 second.
  treasure     = new Treasure();
  hpBar        = new HPBar(10,10,"img/hp.png");
  initGame ();
}

void draw () {

switch (gameState){
    
    // ------------------------
    case GAME_START:   
      image(start2,0,0);
      if(mouseX>200 && mouseX<450 && mouseY>380 && mouseY<410){
        image(start1,0,0);
        if(mousePressed){
          gameState = 1;
        }
      }      
      break;
   //---------------------------   
   case GAME_PLAYING:
     // background and background scrolling effect 
     image(bg1, bg1X-width, 0);
     bg1X += 1;
     bg1X %= 1280;
     image(bg2, bg2X-width, 0);  
     bg2X += 1;
     bg2X %= 1280;
     //treasure
     treasure.display();
     //fighter
     fighter.display();
     fighter.move();
     //bullet
     bullet.display();
     bullet.move();
    
     
     flameManager.display();
     
     
  //===============
  //  ENEMY COLLISION TEST 
  //===============

  for (int i = 0; i < enemyAmount; i++) {
    enemyArray[i].move() ;
     
    // +_+ : collision detection : enemy & bullets  
     for(int j=0;j<5;j++){
      if (enemyArray[i].isHit(bullet.x[j], bullet.y[j], bullet.img.width, bullet.img.height)){  
        //  +_+ : explosion
        flameManager.add(enemyArray[i].x, enemyArray[i].y );
        //  +_+ : then move out the enemy 
        enemyArray[i].x = width ;
        bullet.x[j] = -1000;
        bullet.y[j] = -1000;
      }
    }                  
    
    // +_+ : collision detection : enemy & fighter
    if (enemyArray[i].isHit(fighter.x, fighter.y, fighter.img.width, fighter.img.height )) {
      fighter.hp -= 40;
      //  +_+ : explosion
      flameManager.add(enemyArray[i].x, enemyArray[i].y );
  
      //  +_+ : then move out the enemy 
      enemyArray[i].x = width ;
    }

    // +_+ : show the enemy 
    enemyArray[i].display();
  }

  // +_+ : this will draw all flames.
  flameManager.display();
  
  // +_+ : add some code in the fighter.display method ;

  //===============
  //  REARRANGE ENEMY !! 
  //===============

  // when all enemy is out of screen :  
  if (enemyFinished()) {

    // switch to new enemyState 
    enemyState = (enemyState + 1) % 4 ;

    // arrange enemies to new shape. 
    switch (enemyState) {
    case E_LINE :   
      arrangeLineEnemy() ;   
      break ;
    case E_SLASH :  
      arrangeSlashEnemy() ;  
      break ;
    case E_DIAMOND : 
      arrangeDiamondEnemy() ; 
      break ;
    case E_BOSS :
      arrangeBossEnemy() ;   
      break ;
    }
  }
     //hpBar
     hpBar.display(10);
     //Death
  if(fighter.hp <= 0){
    gameState = 3;
  }     
     break; 
  //---------------------------       
     case GAME_WIN:
     break;
  //---------------------------      
     case GAME_LOSE:   
     image(end2,0,0);
     
        if(mouseX>200 && mouseX<450){
        if(mouseY>310 && mouseY<350){
        image(end1,0,0);
        if(mousePressed){
          //reset the game
          gameState = 1;
          initGame();
        }
       }
      }
     break;
  }
}

void keyPressed(){
  fighter.keyPressed(keyCode) ;
   if(key == ' '){ 
    for(int i=0;i<5;i++){
      if(bullet.x[i]==-1000){
        bullet.x[i] = fighter.x;
        bullet.y[i] = fighter.y;
        break;
      }
    }          
  }
}
void keyReleased(){
  fighter.keyReleased(keyCode) ;
}

void initGame (){
  fighter.hp = 40; //40/200
  fighter.x = width - 50; 
  fighter.y = height /2;
  enemyState = E_LINE ;
  arrangeLineEnemy() ;
  for(int j=0;j<5;j++){
    bullet.x[j] = bullet.y[j] = -1000;
  }
}


boolean isHit(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh)
{
  // Collision x-axis?
  boolean collisionX = (ax + aw >= bx) && (bx + bw >= ax);
  // Collision y-axis?
  boolean collisionY = (ay + ah >= by) && (by + bh >= ay);

  return collisionX && collisionY;
}


boolean enemyFinished() { 

  // if all enemy is out of screen    -> return true
  // if any enemy is inside of screen -> return false 

  for (int i = 0; i < 8; i++) {
    if (enemyArray[i].x < width) {
      return false ;
    }
  }
  return true ;
}


void arrangeLineEnemy () {
  float  y = random (0, 480 - 5 * enemyImg.height);
  for (int i = 0; i < 8; i++) {
    if (i < 5 ) {
      enemyArray[i] = new Enemy( -50 - i * (enemyImg.width + 10) , y ) ;
    } else {
      enemyArray[i] = new Enemy( width, y ) ;
    }
  }
}
void arrangeSlashEnemy () {
  float y = random (0, 480 - 5 * enemyImg.width );
  for (int i = 0; i < 8; i++) {
    if (i < 5 ) {
      enemyArray[i] = new Enemy( -50 - i * 51, y + i * enemyImg.height ) ;
    } else {
      enemyArray[i] = new Enemy( width, y ) ;
    }
  }
}
void arrangeDiamondEnemy () {
  float cx = -250 ;
  float cy = random(0 + 2 * enemyImg.height, 480 - 3 * enemyImg.height ) ;  
  int numPerSide = 3 ;

  int index = 0;
  for (int i = 0; i < numPerSide - 1; i++) {
    int rx = numPerSide - 1 - i ;
    int ry = i ;
    
    enemyArray[index++] = new Enemy( cx + rx * enemyImg.width, cy + ry * enemyImg.height );
    enemyArray[index++] = new Enemy( cx - rx * enemyImg.width, cy - ry * enemyImg.height );
    enemyArray[index++] = new Enemy( cx + ry * enemyImg.width, cy - rx * enemyImg.height );
    enemyArray[index++] = new Enemy( cx - ry * enemyImg.width, cy + rx * enemyImg.height );
  }
}

void arrangeBossEnemy () {
  float y = random( 0, height - 5 * (enemyImg.height + 10) ) ; 
  for (int i = 0; i < 8; i++) {
    if (i < 5 ) {
      enemyArray[i] = new Boss( - width, y + i * (enemyImg.height + 10 ) ) ;
    } else {
      enemyArray[i] = new Boss ( width, y ) ;
    }
  }
}
