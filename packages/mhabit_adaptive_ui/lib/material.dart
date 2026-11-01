/// Material API with dialog-local sizing for the existing date/time pickers.
library;

export 'package:flutter/material.dart' hide showDatePicker, showTimePicker;

export 'src/material/material_date_time_picker.dart'
    show showDatePicker, showTimePicker;
