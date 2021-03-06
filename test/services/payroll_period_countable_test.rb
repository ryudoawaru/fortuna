# frozen_string_literal: true
require "test_helper"

class PayrollPeriodCountableTest < ActiveSupport::TestCase
  def subject(payroll, salary)
    IncomeService.new(payroll, salary)
  end

  def test_first_month_true
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    payroll = build(:payroll, year: 2015, month: 5, employee: employee)
    assert subject(payroll, nil).first_month?
  end

  def test_first_month_false
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    payroll = build(:payroll, year: 2015, month: 6, employee: employee)
    assert_not subject(payroll, nil).first_month?
  end

  def test_final_month_true
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    payroll = build(:payroll, year: 2017, month: 10, employee: employee)
    assert subject(payroll, nil).final_month?
  end

  def test_final_month_false
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    payroll = build(:payroll, year: 2017, month: 2, employee: employee)
    assert_not subject(payroll, nil).final_month?
  end

  def test_payment_period_in_first_month
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2015, month: 5, employee: employee)
    assert_equal subject(payroll, salary).period_length, 18
  end

  def test_employee_on_payroll_in_normal_month
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2015, month: 7, employee: employee)
    assert_equal subject(payroll, salary).period_length, 30
  end

  def test_payment_period_in_final_month
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2017, month: 10, employee: employee)
    assert_equal subject(payroll, salary).period_length, 20
  end

  def test_payment_period_before_employement
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2015, month: 4, employee: employee)
    assert_equal subject(payroll, salary).period_length, 0
  end

  def test_payment_period_after_termination
    employee = build(:employee, start_date: "2015-05-13", end_date: "2017-10-20")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2017, month: 11, employee: employee)
    assert_equal subject(payroll, salary).period_length, 0
  end

  def test_payment_period_30_days_in_february_ongoing_employee
    employee = build(:employee, start_date: "2015-05-13")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2016, month: 2, employee: employee)
    assert_equal subject(payroll, salary).period_length, 30
  end

  def test_payment_period_30_days_in_large_month_ongoing_employee
    employee = build(:employee, start_date: "2015-05-13")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2016, month: 7, employee: employee)
    assert_equal subject(payroll, salary).period_length, 30
  end

  def test_payment_period_30_days_edge_february
    employee = build(:employee, start_date: "2015-05-13", end_date: "2016-02-29")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2016, month: 2, employee: employee)
    assert_equal subject(payroll, salary).period_length, 30
  end

  def test_payment_period_30_days_edge_large_month
    employee = build(:employee, start_date: "2015-05-13", end_date: "2016-07-31")
    salary = build(:salary, effective_date: "2018-05-13", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2016, month: 7, employee: employee)
    assert_equal subject(payroll, salary).period_length, 30
  end

  def test_payment_period_contractor
    employee = build(:employee, start_date: "2018-02-21", end_date: "2018-02-28")
    salary = build(:salary, effective_date: "2018-02-21", employee: employee, role: "contractor")
    payroll = build(:payroll, year: 2018, month: 2, employee: employee)
    assert_equal subject(payroll, salary).period_length, 5
  end

  def test_days_in_cycle_for_regular_employee
    employee = build(:employee, start_date: "2018-02-21")
    salary = create(:salary, effective_date: "2018-02-21", employee: employee, role: "regular")
    payroll = build(:payroll, year: 2018, month: 2, employee: employee)
    assert_equal subject(payroll, salary).days_in_cycle, 30
  end

  def test_days_in_cycle_for_contractor
    employee = build(:employee, start_date: "2018-02-21")
    salary = create(:salary, effective_date: "2018-02-21", employee: employee, role: "contractor")
    payroll = build(:payroll, year: 2018, month: 2, employee: employee)
    assert_equal subject(payroll, salary).days_in_cycle, 15
  end
end
