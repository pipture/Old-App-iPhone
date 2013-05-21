function DaysPickerCtrl($scope) {
    var dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
                    'Friday', 'Saturday', 'Sunday'];
    var dayNamesFr = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi',
                    'Vendredi', 'Samedi', 'Dimanche'];
    $scope.master = {
        model: null,
        choices: {
            all: { value: 'all', label: 'All days', days: '0123456' },
            work: { value: 'work', label: 'Weekdays', days: '01234' },
            end: { value: 'end', label: 'Weekends', days: '56' },
            custom: { value: 'custom', label: 'Custom' }
        }
    };
    $scope.dayModels = dayNames.map(function(day) {
        return {
            name: day,
            model: false
        };
    });

    $scope.update = function() {
        $scope.days = $scope.master.choices[$scope.master.model].days ||
            $scope.dayModels.map(function(day, index) {
                return day.model ? index : '';
            }).join('');
    };

    $scope.init = function() {
        var days = document.getElementById('id_days').value;
        var choices = $scope.master.choices;

        for (var value in choices) {
            if (choices[value].days === days) {
                $scope.master.model = value;
            }
        }
        if (!$scope.master.model) {
            $scope.master.model = 'custom';
            days.split('').forEach(function(value) {
                $scope.dayModels[parseInt(value)].model = true;
            });
        }
    };

    $scope.changeDayNames = function() {
        for (var i = 0, len = $scope.dayModels.length; i < len; i++) {
            $scope.dayModels[i].name = dayNamesFr[i];
        }
    };

    $scope.$watch('dayModels', $scope.update, true);
    $scope.$watch('master.model', $scope.update);
}