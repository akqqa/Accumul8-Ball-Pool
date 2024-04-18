public class Menu {
    PVector position;
    float last_upgrade_position_y;
    float last_ball_position_y;
    float menu_width;
    float menu_height;
    String menu_title = "Upgrade Menu";
    int random_num_of_options;
    Button[] upgrade_buttons = new Button[3];
    Button[] ball_buttons = new Button[2];
    Button confirmation_button;

    Button selected_upgrade_button;
    Button selected_ball_button;
    // instruction message
    String menu_message = "Please select 1 upgrade AND\n1 ball to add into inventory";
    public Menu (float _x, float _y, float _width, float _height) {
        position = new PVector(_x, _y);
        this.menu_width = _width;
        this.menu_height = _height;
        random_num_of_options = int(random(2, 4));
        // debug: random_num_of_options
        println("random_num_of_options: "+random_num_of_options);
        for (int i = 0; i < random_num_of_options; ++i) {
            int random_element = int(random(elements.length));
            int random_percentage = int(random(percentages.length));
            int random_upgrade_type = int(random(upgrade_types.length));

            // check duplication
            for (int j = 0; j < i;) {
                if (upgrade_buttons[j].button_element.equals(elements[random_element]) && upgrade_buttons[j].button_type.equals(upgrade_types[random_upgrade_type])) {
                    random_element = int(random(elements.length));
                    random_upgrade_type = int(random(upgrade_types.length));
                    j = 0;
                } else {
                    j++;
                }
            }
            // Button (float _x, float _y, float _width, float _height, int _amount, String _element, String _type, int r, int g, int b)
            Button button = new Button(screen_width*0.85, (screen_height*0.3 + i*50), this.menu_width* 0.8, 30, percentages[random_percentage], elements[random_element], upgrade_types[random_upgrade_type], 30, 0, 20);
            upgrade_buttons[i] = button;
            if (i == random_num_of_options - 1) {
                last_upgrade_position_y = (screen_height*0.3 + i*50);
            }
        }
        for (int k = 0; k < ball_buttons.length; k++) {
            int random_element = int(random(elements.length));
            // check duplication
            if (k == ball_buttons.length - 1) {
                while (ball_buttons[0].button_element.equals(elements[random_element])) {
                    random_element = int(random(elements.length));
                }
                last_ball_position_y = (last_upgrade_position_y + (k + 2) * 50);
            }
            Button button = new Button(screen_width*0.85, (last_upgrade_position_y + (k + 2) * 50), this.menu_width * 0.8, 30, 1, elements[random_element], "ball", 0, 30, 20);
            
            ball_buttons[k] = button;
            
        }

        confirmation_button = new Button(screen_width*0.85, last_ball_position_y + 50, this.menu_width * 0.8, 30, 0, "", "confirmation", 0, 0, 150);
    }
    public void display() {
        rectMode(CENTER);
        fill(255);
        rect(this.position.copy().x, this.position.copy().y, this.menu_width, this.menu_height);
        textAlign(CENTER, CENTER);
        
        fill(0);
        textSize(36);
        text(this.menu_title, this.position.copy().x, this.position.copy().y - this.menu_height/2 + 50);

        textSize(20);
        text(this.menu_message, this.position.copy().x, this.position.copy().y - this.menu_height/3);

        // upgrade buttons
        for (int i = 0; i < random_num_of_options; i++) {
            upgrade_buttons[i].update();
            if (upgrade_buttons[i].button_clicked) {
                selected_upgrade_button = upgrade_buttons[i];
                for (int j = 0; j < random_num_of_options; j++) {
                    if (j != i) {
                        upgrade_buttons[j].button_clicked = false;
                    }
                }
            }
            upgrade_buttons[i].display();
        }

        textSize(20);
        textAlign(CENTER, CENTER);
        text("AND", this.position.copy().x, upgrade_buttons[random_num_of_options-1].position.copy().y + 50);

        for (int k = 0; k < ball_buttons.length; k++) {
            Button ball_button = ball_buttons[k];
            ball_button.update();
            if (ball_button.button_clicked) {
                selected_ball_button = ball_button;
                for (int l = 0; l < ball_buttons.length; ++l) {
                    if(l != k) {
                        ball_buttons[l].button_clicked = false;
                    }
                }
            }
            ball_button.display();
        }
        // only show confirmation button when upgrade and ball are both selected
        if (checkSelected(upgrade_buttons) && checkSelected(ball_buttons)) {
            confirmation_button.update();
            confirmation_button.display();
            if (confirmation_button.button_clicked) {
                // selected_upgrade_button.applyChanges();
                // selected_ball_button.applyChanges();
                for (int i = 0; i < ball_buttons.length; i++) {
                    Button ball_button = ball_buttons[i];
                    if (ball_button.button_clicked) {
                        ball_button.applyChanges();
                    }
                }

                for (int j = 0; j < random_num_of_options; j++) {
                    Button upgrade_button = upgrade_buttons[j];
                    if (upgrade_button.button_clicked) {
                        upgrade_button.applyChanges();
                    }
                }
                state = game_state;
                points_needed = 100;
                cue.setActive(true);
            }
        }
        
    }
    public boolean checkSelected(Button[] button_arr) {
        for (int i = 0; i < button_arr.length; i++) {
            if (button_arr[i] == null) {
                continue;
            }
            if (button_arr[i].button_clicked) {
                return true;
            }
        }
        return false;
    }
}
