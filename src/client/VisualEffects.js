class ProgramTable {
    constructor() {
        this.program_table_btn = document.getElementById("ToggleProgramTable");
        this.program_table = document.getElementById("ProgramTable");
        this.is_shown = false;
    }

    Toggle() {
        this.is_shown = !this.is_shown;

        // show the program table
        if(this.is_shown) {
            this.program_table.style.display = "table";
            this.program_table_btn.innerHTML = "Hide the program table";
        }

        else {
            this.program_table.style.display = "none";
            this.program_table_btn.innerHTML = "Show the program table";
        }
    }
};

// create objects
let g_ProgramTable = new ProgramTable();
