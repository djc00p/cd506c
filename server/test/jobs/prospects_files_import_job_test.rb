require "test_helper"

class ProspectsFilesImportJobTest < ActiveJob::TestCase
  include ActionDispatch::TestProcess

  setup do
    @file1 = fixture_file_upload("test.csv",  "text/csv")
    @file2 = fixture_file_upload("test2.csv",  "text/csv")
    @file3 = fixture_file_upload("test3.csv",  "text/csv")
    @file4 = fixture_file_upload("test4.csv",  "text/csv")
    prospects_files(:pf1).file.attach(@file1)
    prospects_files(:pf2).file.attach(@file2)
    prospects_files(:pf3).file.attach(@file3)
    prospects_files(:pf4).file.attach(@file4)
    @prospects_files1 = prospects_files(:pf1)
    @prospects_files2 = prospects_files(:pf2)
    @prospects_files3 = prospects_files(:pf3)
    @prospects_files4 = prospects_files(:pf4)
  end

  test "job add to queue" do
    assert_no_enqueued_jobs

    ProspectsFilesImportJob.perform_later(@prospects_files1.id)

    assert_enqueued_jobs 1
  end

  test "preformed job" do
    assert_no_performed_jobs

    perform_enqueued_jobs do
      ProspectsFilesImportJob.perform_later(@prospects_files2.id)
    end

    assert_performed_jobs 1
  end

  test "preformed job and new prospects are added" do
    assert_equal(Prospect.count, 4)

    perform_enqueued_jobs do
      ProspectsFilesImportJob.perform_now(@prospects_files1.id)
      assert_equal(Prospect.count, 104)
    end
  end

  test "test job matches index and updates if force? is true and has_headers? is false" do
    assert_equal(prospects(:one).first_name, "MyText")

    perform_enqueued_jobs do
      ProspectsFilesImportJob.perform_now(@prospects_files2.id)

      assert_equal(Prospect.where(email: prospects(:one).email)[0].first_name, "NewName")
    end
  end

  test "test job matches index and  does not update if force? is false" do
    assert_equal(Prospect.where(email: prospects(:one).email).count, 4)

    perform_enqueued_jobs do
      ProspectsFilesImportJob.perform_now(@prospects_files3.id)

      assert_equal(Prospect.where(email: prospects(:one).email).count, 5)
    end
  end

  test "test job creates new Prospects if has_headers? is true and force? is false" do
    assert_equal(Prospect.count, 4)

    perform_enqueued_jobs do
      ProspectsFilesImportJob.perform_now(@prospects_files3.id)

      assert_equal(Prospect.count, 105)
      assert_equal(Prospect.where(email: prospects(:one).email).count, 5)
    end
  end

  test "test job creates new Prospects if has_headers? is false and force? is false" do
    assert_equal(Prospect.count, 4)
    assert_equal(Prospect.where(email: "mahro@ew.gg").count, 0)

    perform_enqueued_jobs do
      ProspectsFilesImportJob.perform_now(@prospects_files4.id)

    assert_equal(Prospect.count, 107)
    assert_equal(Prospect.where(email: "mahro@ew.gg").count, 2)
    end
  end
end
