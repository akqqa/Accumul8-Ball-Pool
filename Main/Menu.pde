public class Menu {
    PVector position;
    float last_upgrade_position_y;
    float last_ball_position_y;
    float menu_width;
    float menu_height;
    String menu_title = "Upgrade Menu";
    float upgrade_buttons_start = screen_height * 0.3;
    int num_of_options;
    Button[] upgrade_buttons = new Button[3];
    Button[] ball_buttons = new Button[2];
    Button confirmation_button;
    Button skip_button;

    Button selected_upgrade_button;
    Button selected_ball_button;
    
    
    // instruction message
    String menu_message = "Please select\n 1 upgrade and 1 ball\n to add to inventory";
    public Menu (float _x, float _y, float _width, float _height) {
        position = new PVector(_x, _y);
        this.menu_width = _width;
        this.menu_height = _height;
        num_of_options = 3; // Not random anymore
        ArrayList<Object[]> possibleUpgrades = new ArrayList<Object[]>();
        Object[] arr;
        // if (fireMultiplier < fireMultiplierMax) {
        //     arr = new Object[]{fireMultiplierIncrement, "fire", "points", "+" + str(fireMultiplierIncrement*points_per_ball) + " fire points"};
        //     possibleUpgrades.add(arr);
        // }
        // if (fireRadius < fireRadiusMax) {
        //     arr = new Object[]{fireRadiusIncrement, "fire", "radius", "Increase fire radius"};
        //     possibleUpgrades.add(arr);
        // }
        // if (shockMultiplier < shockMultiplierMax) {
        //     arr = new Object[]{shockMultiplierIncrement, "electricity", "points", "+" + str(shockMultiplierIncrement*points_per_ball) + " shock points"};
        //     possibleUpgrades.add(arr);
        // }
        // if (shockChains < shockChainsMax) {
        //     arr = new Object[]{(float) shockChainsIncrement, "electricity", "chains", "+" + str(shockChainsIncrement) + " shock chain"};
        //     possibleUpgrades.add(arr);
        // }
        // if (frozenMultiplier < frozenMultiplierMax) {
        //     arr = new Object[]{frozenMultiplierIncrement, "ice", "points", "+" + str(frozenMultiplierIncrement*points_per_ball) + " freeze points"};
        //     possibleUpgrades.add(arr);
        // }
        // if (freezeDuration < freezeDurationMax) {
        //     arr = new Object[]{(float) freezeDurationIncrement, "ice", "duration", "+" + freezeDurationIncrement + " freeze duration"};
        //     possibleUpgrades.add(arr);
        // }
        if (gravityMultiplier < gravityMultiplierMax) {
            arr = new Object[]{gravityMultiplierIncrement, "gravity", "points", "+" + str(gravityMultiplierIncrement*points_per_ball) + " gravity points"};
            possibleUpgrades.add(arr);
        }
        if (gravityRadius < gravityRadiusMax) {
            arr = new Object[]{gravityRadiusIncrement, "gravity", "radius", "Increase gravity radius"};
            possibleUpgrades.add(arr);
        }

        for (int i = 0; i < num_of_options; ++i) {
            // Pick upgrades to display
            // Pick random upgrade from possibleUpgrades, and make button for it. If none left, dont make a button
            Object[] chosenUpgrade = null;
            if (!possibleUpgrades.isEmpty()) {
            //     // do nothing
            // } else {
                int random_upgrade = int(random(possibleUpgrades.size()));
                chosenUpgrade = possibleUpgrades.get(random_upgrade);
                possibleUpgrades.remove(chosenUpgrade);
            }
            

            // create the button with the respective upgrades and position set according to i
            // constructor Button (float _x, float _y, float _width, float _height, int _amount, String _element, String _type, int r, int g, int b)
            Button button;
            if (chosenUpgrade == null) {
                button = new Button(screen_width*0.85, (/* screen_height*0.3 */upgrade_buttons_start + i*50), this.menu_width * 0.9, 30, 0, "", ""/* , 30, 0, 20 */);
            } else {
                button = new Button(screen_width*0.85, (/* screen_height*0.3 */upgrade_buttons_start + i*50), this.menu_width * 0.9, 30, (float) chosenUpgrade[0], (String) chosenUpgrade[1], (String) chosenUpgrade[2]/* , 30, 0, 20 */);
                button.setText((String) chosenUpgrade[3]);
            }
            // add the button into array
            upgrade_buttons[i] = button;
            if (i == num_of_options - 1) {
                // save the last  position for next part of the menu
                last_upgrade_position_y = (/* screen_height*0.3 */upgrade_buttons_start + i*50);
            }
        }

        // reset last upgrade position if all upgrades are null
        if (checkAllButtonNull(upgrade_buttons)) {
            menu_message = "Please select a ball\nthat you like to add into\ninventory or skip";
            last_upgrade_position_y = /* screen_height * 0.3 */upgrade_buttons_start;
        }

        // ball addition buttons
        for (int k = 0; k < ball_buttons.length; k++) {
            int random_element = int(random(elements.length));
            // check duplication
            if (k == ball_buttons.length - 1) {
                while (ball_buttons[0].button_element.equals(elements[random_element])) {
                    // generate the element again
                    random_element = int(random(elements.length));
                }
                // save the last ball addition button for positioning the confirmation button
                // it will be different according to whether upgrades are all null
                if (checkAllButtonNull(upgrade_buttons)) {
                    last_ball_position_y = (last_upgrade_position_y + k * 50);
                } else {
                    last_ball_position_y = (last_upgrade_position_y + (k + 2) * 50);
                }
                
            }
            Button button = new Button(screen_width*0.85, (last_upgrade_position_y + (k + 2) * 50), this.menu_width * 0.9, 30, 1, elements[random_element], "ball"/* , 0, 30, 20 */);
            if (checkAllButtonNull(upgrade_buttons)) {
                button = new Button(screen_width*0.85, (last_upgrade_position_y + k * 50), this.menu_width * 0.9, 30, 1, elements[random_element], "ball"/* , 0, 30, 20 */);
            }
            // add the button to ball buttons array
            ball_buttons[k] = button;
            
        }

        // create the confirmation button for the upgrades and ball addition
        confirmation_button = new Button(screen_width*0.85, last_ball_position_y + 50, this.menu_width * 0.9, 30, 0, "", "confirmation"/* , 0, 0, 150 */);
        skip_button = new Button(screen_width*0.85, last_ball_position_y + 2 * 50, this.menu_width * 0.9, 30, 0, "", "skip"/* , 0, 0, 150 */);
    }

    // displaying the menu with the buttons in different parts
    public void display() {
        // the rectangle surrounding the whole menu
        rectMode(CENTER);
        fill(0, 0, 255, 128);
        rect(this.position.copy().x, this.position.copy().y, this.menu_width, this.menu_height);
        textAlign(CENTER, CENTER);
        
        // show the menu title at the center top (of the right part of the screen)
        fill(0);
        textSize(30);
        text(this.menu_title, this.position.copy().x, this.position.copy().y - this.menu_height/2 + 50);

        // the following is the instruction message for players to select the upgrades and ball addition
        textSize(14);
        text(this.menu_message, this.position.copy().x, this.position.copy().y - this.menu_height/3);

        // upgrade buttons
        // only display if they are not all null
        if (!checkAllButtonNull(upgrade_buttons)) {
            for (int i = 0; i < num_of_options; i++) {
                // if hover or clicked, update the button booleans
                upgrade_buttons[i].update(i);
                if (upgrade_buttons[i].button_clicked) {
                    // check if any other upgrade button is selected, if so, set button clicked to false, leaving only the current button as clicked
                    selected_upgrade_button = upgrade_buttons[i];
                    for (int j = 0; j < num_of_options; j++) {
                        if (j != i) {
                            upgrade_buttons[j].button_clicked = false;
                        }
                    }
                }
            // display the button showing whether cursor is inside the button, clicking the button
            upgrade_buttons[i].display();
            }
        }
        

        // text to separate the upgrades and the ball addition buttons
        if (!checkAllButtonNull(upgrade_buttons)) {
            textSize(15);
            textAlign(CENTER, CENTER);
            text("AND", this.position.copy().x, upgrade_buttons[num_of_options-1].position.copy().y + 50);
        }
        
        
        skip_button.update(0);
        skip_button.display();
        // continue to game if skip button is clicked
        if (skip_button.button_clicked) {
            state = game_state;
            cue.setActive(true);
        }
        // ball addition buttons
        for (int k = 0; k < ball_buttons.length; k++) {
            Button ball_button = ball_buttons[k];
            // check if cursor is inside or clicked, update the button booleans
            ball_button.update(k);
            if (ball_button.button_clicked) {
                // check if any other ball addition button is selected, if so, set button clicked to false, leaving only the current button as clicked
                selected_ball_button = ball_button;
                for (int l = 0; l < ball_buttons.length; l++) {
                    if(l != k) {
                        ball_buttons[l].button_clicked = false;
                    }
                }
            }
            ball_button.display();
        }
        
        
        // only show confirmation button when either upgrade or ball is selected
        if (checkSelected(upgrade_buttons) || checkSelected(ball_buttons)) {
            // check if cursor inside button or clicking button
            confirmation_button.update(0);
            confirmation_button.display();
            if (confirmation_button.button_clicked) {
                // apply upgrade only if selected upgrade button is not null
                if (selected_upgrade_button != null) {
                    selected_upgrade_button.applyChanges();
                }
                
                // apply ball addition only if selected ball button is not null
                if (selected_ball_button != null) {
                    selected_ball_button.applyChanges();
                }
                
                // for (int i = 0; i < ball_buttons.length; i++) {
                //     Button ball_button = ball_buttons[i];
                //     if (ball_button.button_clicked) {
                //         ball_button.applyChanges();
                //     }
                // }

                // for (int j = 0; j < num_of_options; j++) {
                //     Button upgrade_button = upgrade_buttons[j];
                //     if (upgrade_button.button_clicked) {
                //         upgrade_button.applyChanges();
                //     }
                // }

                // update the state, back to the game
                state = game_state;
                // TODO: currently hard set to 100, you might have other ways updating points required
                cue.setActive(true);
            }
        }
        
    }
    // check if there is a selected button from that part (upgrades or ball addition)
    public boolean checkSelected(Button[] button_arr) {
        for (int i = 0; i < button_arr.length; i++) {
            if (button_arr[i] == null) {
                // in the case of 3rd element where there is only 2 upgrade buttons
                continue;
            }
            if (button_arr[i].button_clicked) {
                return true;
            }
        }
        return false;
    }

    // check if all buttons are null
    public boolean checkAllButtonNull(Button[]button_arr) {
        for (int i = 0; i < button_arr.length; i++) {
             if (button_arr[i] == null) {
                // in the case of 3rd element where there is only 2 upgrade buttons
                continue;
            }
            if (!button_arr[i].button_type.equals("")) {
                return false;
            }
        }
        return true;
    }
}
