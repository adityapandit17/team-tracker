# Creates a draft ProjectBilling for every eligible monthly project
# for the month that just ended (run on the 1st via Solid Queue recurring schedule).
class GenerateMonthlyDraftBillingsJob < ApplicationJob
  queue_as :default

  def perform(as_of: Time.zone.today)
    as_of = as_of.to_date
    # When run on the 1st, target the previous calendar month that just closed.
    billing_month = (as_of.day == 1 ? as_of.prev_month : as_of).beginning_of_month

    result = Project.create_monthly_draft_billings!(billing_month: billing_month)
    Rails.logger.info(
      "[GenerateMonthlyDraftBillingsJob] month=#{billing_month} " \
      "created=#{result[:created]} skipped=#{result[:skipped]} projects=#{result[:considered]}"
    )
    result
  end
end
