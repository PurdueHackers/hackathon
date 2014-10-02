class ExecsController < ApplicationController
  load_and_authorize_resource
  def applied
    @count = Hacker.all.count
  end

  def sticker_recipients
    deadline = Time.parse('July 15th 2014 11:59pm PST')
    @hackers = Hacker.where('created_at < ?', deadline ).select do |h|
      h.eligible_for_sticker?
    end
    respond_to do |format|
      format.json { render @hackers }
      format.html { render 'sticker_recipients' }
    end
  end

  def shirts
    @shirt_sizes = ['Small', 'Medium', 'Large', 'XL', 'XXL']
    @shirts = Hash.new
    @shirt_sizes.each do |size|
      @shirts[size] = Hacker.joins(:application).where(applications: {tshirt_size: size}).count
    end
  end

  def exportall
    require 'csv'
    @csv_string = CSV.generate do |csv|
      csv << ['id', 'fname', 'lname', 'email', 'school', 'team', 'status', 'confirmed']
      Hacker.all.each do |h|
        school_name = ''
        team_id     = 0
        if h[:school_id].present? && h[:school_id] != -1
          school_name = School.find(h[:school_id]).name
        end
        if h.team.present?
          team_id = h.team.id
        end
        csv << [h.id,
                h.first_name,
                h.last_name,
                h.email,
                school_name,
                team_id,
                h.status,
                h.confirmed]
      end
    end
    send_data @csv_string,
              :filename => "all-hackers.csv",
              :type => "text/csv"
  end

  def export
    require 'csv'
    @csv_string = CSV.generate do |csv|
      csv << ['id', 'name', 'github', 'school', 'essay', 'team']
      Hacker.all.each do |h|
        school_name = ''
        prev_exp    = ''
        team_id     = 0
        if h[:school_id].present? && h[:school_id] != -1
          school_name = School.find(h[:school_id]).name
        end
        if h.team.present?
          team_id = h.team.id
        end
        if h.application.present?
          if h.application.previous_experience.present?
            prev_exp = h.application.previous_experience
          end
            csv << [h.id,
                    h.full_name,
                    h.application.github,
                    school_name,
                    prev_exp,
                    team_id]
        end
      end
    end
    send_data @csv_string,
              :filename => "hackers.csv",
              :type => "text/csv"
  end

  def hackers_for
    @school = School.find params[:school_id]
    @hackers = @school.users
  end


  def dashboard
    @confirmed_count = Hacker.where(confirmed: true).count
    @applied_count = Hacker.all.count
    @schools = Hacker.all.map{ |h| h.school }.keep_if{ |h| h.present? }.uniq.sort_by do |s|
      s.users.count
    end.reverse

    @school_count = @schools.count

    @focus_schools = []
    @focus_schools << School.find_by(name: 'University of Illinois-Urbana-Champaign (IL)')
    @focus_schools << School.find_by(name: 'Purdue University (IN)')
    @focus_schools << School.find_by(name: 'Rose-Hulman Institute of Technology (IN)')
    @focus_schools << School.find_by(name: 'Ohio State University (OH)')
    @focus_schools << School.find_by(name: 'University of Wisconsin-Madison (WI)')
    @focus_schools << School.find_by(name: 'University of Cincinnati (OH)')
    @focus_schools << School.find_by(name: 'University of Maryland - College Park (MD)')
    @focus_schools << School.find_by(name: 'University of Michigan (MI)')
    if Rails.env.production?
      @focus_schools << School.find(1688)
    else
      @focus_schools << School.find_by(name: 'Univeristy of Waterloo (INT)')
    end
    @focus_schools << School.find_by(name: 'Northwestern University (IL)')
    @focus_schools << School.find_by(name: 'Massachusetts Institute of Technology (MA)')
    @focus_schools << School.find_by(name: 'Carnegie Mellon University (PA)')
    @focus_schools << School.find_by(name: 'University of California-Los Angeles (CA)')
    @focus_schools << School.find_by(name: 'McGill University (INT)')
    @focus_schools << School.find_by(name: 'Pennsylvania State University (PA)')
    @focus_schools << School.find_by(name: 'University of California-Berkeley (CA)')
    @focus_schools << School.find_by(name: 'University of Iowa (IA)')

  end

  private
  def difference_in_days earliest, latest
    ( (latest - earliest) / (60 * 60 * 24) ).floor
  end
end
