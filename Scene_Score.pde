import java.util.Date;
import java.text.SimpleDateFormat;

class Scene_Score implements Scene {
  boolean textInputting = true;
  String textInputted = "";

  int millisAtSceneInit = -1;
  int afkTimerMillis = 1000 * 20;
  int afkCountdownMillis = 1000 * 10; //how many millis must be left before it actually shows the countdown

  int topCount = 10; //amount of players that is visible in the list

  boolean shouldGoToNextScene = false;

  void restartAfkCountdown() {
    millisAtSceneInit = millis();
  }

  void init() {
    textInputting = true;
    textInputted = "";
    restartAfkCountdown();
  }

  void step() {
    background(0);

    // --- Vertical split line through the middle ---
    stroke(255);
    strokeWeight(2);
    line(width/2, 0, width/2, height);


    // --- AFK Countdown Timer ---
    int millisSinceSceneInit = millis() - millisAtSceneInit;
    int millisLeft = afkTimerMillis - millisSinceSceneInit;
    if (millisLeft <= afkCountdownMillis) {
      textAlign(CENTER, CENTER);
      int secondsLeft = millisLeft/1000;
      //height
      float alarmness = map(secondsLeft, afkCountdownMillis/1000, 0, 0, 100);
      float textHeight = 48 + alarmness;
      textSize(textHeight);

      //width
      String text = str(secondsLeft + 1);
      float textWidth = textWidth(text);

      rectMode(CENTER);
      fill(0);
      noStroke();
      rect(width/2, height/2, textWidth, textHeight);

      fill(255);
      textFont(fntOrbitronBlack);
      text(text, width/2, height/2);

      if (millisLeft <= 0) {
        gameState.nextScene();
      }
    }

    fill(255);
    textAlign(CENTER, TOP);


    // --- Submit score ---

    textFont(fntOrbitronRegular);
    textSize(48);
    text("Your score:", width/4f, height*0.1);

    textFont(fntOrbitronBlack);
    textSize(148);
    text(nfc(score), width/4f, height*0.2);

    textFont(fntOrbitronBold);
    textSize(48);
    text("Name:", width/4, height*0.5);

    textSize(128);
    rectMode(CENTER);
    noStroke();
    textFont(fntOCR_A);
    float charWidth = 80;
    for (int i = 0; i < 3; i++) {
      float x = (width/4) - charWidth + (charWidth * i);
      float y = height*0.6;
      if (millis() % 1060 > 530 && i == textInputted.length()) {
        fill(255);
      } else {
        fill(255, 50);
      }
      //rect(x, y + 100, charWidth-10, 5); //underline
      rect(x, y + 42, charWidth-10, 100); //block
      if (i < textInputted.length()) {
        fill(255);
        text(textInputted.charAt(i), x, y);
      }
    }

    fill(255);
    textFont(fntOrbitronRegular);
    textSize(48);
    if (textInputting) {
      if (textInputted.length() != 3) {
        text("Type your user tag!", width/4, height*0.9);
      } else {
        text("Enter to submit!", width/4, height*0.9);
      }
    } else {
      textSize(48);
      text("Press space or click to go the menu", width/4, height*0.9);
    }

    // --- Highscores list ---

    textFont(fntOrbitronRegular);
    textSize(48);
    text("Highscores:", width/4f*3, height*0.1);

    pushMatrix();
    float w = width/3;
    translate(width/2 + w/4, height*0.2);
    for (int i = 0; i < (highscores.getRowCount() < topCount ? highscores.getRowCount() : topCount); i++) {
      float y = i * 50 + 10;
      TableRow tr = highscores.getRow(i);
      textAlign(LEFT, TOP);
      textFont(fntOCR_A);
      textSize(48);
      text(tr.getString("name"), 32, y);
      textAlign(RIGHT, TOP);
      textFont(fntOrbitronRegular);
      textSize(48);
      text(nfc(tr.getInt("score")), w-32, y);
    }
    popMatrix();
  }

  void mousePressed() {
    restartAfkCountdown();
  }

  void mouseDragged() {
    restartAfkCountdown();
  }

  void mouseReleased() {
    restartAfkCountdown();
    if (!textInputting) {
      gameState.nextScene();
    }
  }

  void mouseWheel(MouseEvent event) {
    restartAfkCountdown();
  }

  void keyPressed() {
    restartAfkCountdown();
    if (textInputting) {
      if (key == BACKSPACE || key == DELETE) {
        if (textInputted.length() > 0) {
          textInputted = textInputted.substring(0, textInputted.length() - 1);
          sfxTyped.play();
        }
      } else if ((key == RETURN || key == ENTER) && textInputted.length() == 3) {
        textInputting = false;

        TableRow newRow = highscores.addRow();
        newRow.setString("name", textInputted);
        SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
        Date now = new Date();
        String strDate = sdfDate.format(now);
        newRow.setString("time", strDate);
        newRow.setInt("score", score);

        highscores.trim();
        highscores.sortReverse("score");
        saveTable(highscores, "data/highscores.csv");

        int index = highscores.findRowIndex(strDate, "time");
        if (index == 0) {
          sfxHighscoresTop.play();
        } else if (index <= topCount) {
          sfxHighscores.play();
        }
      } else if (key != CODED) {
        if (Character.isLetter(key) || Character.isDigit(key)) {
          if (textInputted.length() < 3) {
            textInputted += Character.toUpperCase(key);
            sfxTyped.play();
          }
        }
      }
    }
  }

  void keyReleased() {
    restartAfkCountdown();
    if (!textInputting) {
      if (key == ' ') {
        gameState.nextScene();
      }
    }
  }

  void cleanup() {
  }
}
