# frozen_string_literal: true
class StatementNotesService
  include PayrollPeriodCountable

  attr_reader :payroll, :salary, :notes

  def initialize(payroll, salary)
    @payroll = payroll
    @salary = salary
    @notes = []
  end

  def run
    employment_date_notes
    hourly_based_note(payroll.parttime_hours, "工作時數")
    hourly_based_note(payroll.vacation_refund_hours, "特休折現")
    overtime_notes
    hourly_based_note(payroll.leavetime_hours, "扣薪事假")
    hourly_based_note(payroll.sicktime_hours, "扣薪病假")
    extra_notes
    notes
  end

  private

  def hourly_based_note(hours, title)
    notes << "#{title} #{hours} 小時" if hours.positive?
  end

  def employment_date_notes
    notes << "#{payroll.employee.start_date} 到職" if first_month?
    notes << "#{payroll.employee.end_date} 離職" if final_month?
  end

  def overtime_notes
    payroll.overtimes.map do |overtime|
      notes << "#{overtime.date.strftime('%Y-%m-%d')} 加班 #{overtime.hours} 小時"
    end
  end

  def extra_notes
    payroll.extra_entries.map do |extra_entry|
      notes << extra_entry.note if extra_entry.note.present?
    end
  end
end
