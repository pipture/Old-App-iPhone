from datetime import timedelta, date
from django import forms
from restserver.pipture.models import TimeSlots


class AdminTimeSlotsForm(forms.ModelForm):
    class Meta:
        model = TimeSlots

    def clean_StartDate(self):
        start_date = self.cleaned_data['StartDate']

        if start_date < date.today() + timedelta(days=2):
            raise forms.ValidationError(
                    'The start day should be set to minimum +2 days from today'
                )

        return start_date