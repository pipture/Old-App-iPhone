from django import forms
from django.utils.safestring import mark_safe


class DaysPicker(forms.TextInput):
    class Media:
        js = (
            'days_picker/js/angular.min.js',
            'days_picker/js/DaysPicker.js',
        )
        css = {
            'all': ('days_picker/css/days_picker.css',)
        }

    html = \
        """
        <div class="days-picker" ng-app>
            <div ng-controller="DaysPickerCtrl" ng-init="init()">
                <div ng-hide="true">%(input)s</div>
                <ul class="master-choice">
                    <li ng-repeat="choice in master.choices">
                        <label><input type="radio" ng-model="master.model"
                            value="{{ choice.value }}">{{ choice.label }}</label>
                    </li>
                </ul>
                <ul class="custom-choice"
                    ng-show="master.model == master.choices.custom.value">
                    <li ng-repeat="day in dayModels">
                        <label><input type="checkbox"
                        ng-model="day.model">{{ day.name }}</label>
                    </li>
                </ul>
            </div>
        </div>
        """

    def render(self, name, value, attrs=None):
        attrs = attrs or {}
        attrs['ng-model'] = 'days'
        input = super(DaysPicker, self).render(name, value, attrs)
        return mark_safe(self.html % dict(input=input))
