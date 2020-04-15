# frozen_string_literal: true

shared_examples CMSScanner::References do
  describe '#references_keys' do
    it 'returns the expected array of symbols' do
      expect(subject.class.references_keys)
        .to eql %i[cve exploitdb url metasploit packetstorm securityfocus youtube]
    end
  end

  describe 'references' do
    context 'when no references' do
      %i[cves exploitdb_ids urls msf_modules packetstorm_ids securityfocus_ids youtube_urls].each do |attribute|
        its(attribute) { should eql([]) }
      end

      %i[cve_urls exploitdb_urls msf_urls packetstorm_urls securityfocus_urls youtube_urls].each do |attribute|
        its(attribute) { should eql([]) }
      end

      its(:references_urls) { should eql([]) }
    end

    context 'when an unknown reference key is provided' do
      let(:references) { { cve: 1, unknown: 12 } }

      its(:references) { should eql(cve: %w[1]) }
    end

    context 'when references provided as string/integer' do
      let(:references) do
        {
          cve: '11',
          secunia: '12', # Secunia and OSVDB have been left here to make sure they don't raise errors
          osvdb: '13',
          exploitdb: '14',
          url: 'single-url',
          metasploit: '/exploit/yolo',
          packetstorm: 15,
          securityfocus: 16,
          youtube: 'xAAAA'
        }
      end

      its(:cves)     { should eql %w[11] }
      its(:cve_urls) { should eql %w[https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11] }

      its(:exploitdb_ids)  { should eql %w[14] }
      its(:exploitdb_urls) { should eql %w[https://www.exploit-db.com/exploits/14/] }

      its(:urls) { should eql %w[single-url] }

      its(:msf_modules) { should eql %w[/exploit/yolo] }
      its(:msf_urls) { should eql %w[https://www.rapid7.com/db/modules/exploit/yolo] }

      its(:packetstorm_ids)  { should eq %w[15] }
      its(:packetstorm_urls) { should eql %w[https://packetstormsecurity.com/files/15/] }

      its(:securityfocus_ids)  { should eq %w[16] }
      its(:securityfocus_urls) { should eql %w[https://www.securityfocus.com/bid/16/] }

      its(:youtube_urls) { should eql %w[https://www.youtube.com/watch?v=xAAAA] }

      its(:references_urls) do
        should eql [
          'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11',
          'https://www.exploit-db.com/exploits/14/',
          'single-url',
          'https://www.rapid7.com/db/modules/exploit/yolo',
          'https://packetstormsecurity.com/files/15/',
          'https://www.securityfocus.com/bid/16/',
          'https://www.youtube.com/watch?v=xAAAA'
        ]
      end
    end

    context 'when references provided as array' do
      let(:references) do
        {
          cve: [10, 11],
          secunia: [20, 21], # Secunia and OSVDB have been left here to make sure they don't raise errors
          osvdb: [30, 31],
          exploitdb: [40, 41],
          url: %w[single-url another-url],
          metasploit: %w[/exploit/yolo exploit/aa],
          packetstorm: [50, 51],
          securityfocus: [60, 61],
          youtube: %w[xBBBB]
        }
      end

      its(:cves) { should eql %w[10 11] }
      its(:cve_urls) do
        should eql %w[https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-10
                      https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11]
      end

      its(:exploitdb_ids) { should eql %w[40 41] }
      its(:exploitdb_urls) do
        should eql %w[https://www.exploit-db.com/exploits/40/
                      https://www.exploit-db.com/exploits/41/]
      end

      its(:urls) { should eql %w[single-url another-url] }

      its(:msf_modules) { should eql %w[/exploit/yolo exploit/aa] }
      its(:msf_urls) do
        should eql %w[https://www.rapid7.com/db/modules/exploit/yolo
                      https://www.rapid7.com/db/modules/exploit/aa]
      end

      its(:packetstorm_ids) { should eq %w[50 51] }
      its(:packetstorm_urls) do
        should eql %w[https://packetstormsecurity.com/files/50/
                      https://packetstormsecurity.com/files/51/]
      end

      its(:securityfocus_ids)  { should eq %w[60 61] }
      its(:securityfocus_urls) do
        should eql %w[https://www.securityfocus.com/bid/60/
                      https://www.securityfocus.com/bid/61/]
      end

      its(:youtube_urls) { should eql %w[https://www.youtube.com/watch?v=xBBBB] }

      its(:references_urls) do
        should eql [
          'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-10',
          'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11',
          'https://www.exploit-db.com/exploits/40/',
          'https://www.exploit-db.com/exploits/41/',
          'single-url',
          'another-url',
          'https://www.rapid7.com/db/modules/exploit/yolo',
          'https://www.rapid7.com/db/modules/exploit/aa',
          'https://packetstormsecurity.com/files/50/',
          'https://packetstormsecurity.com/files/51/',
          'https://www.securityfocus.com/bid/60/',
          'https://www.securityfocus.com/bid/61/',
          'https://www.youtube.com/watch?v=xBBBB'
        ]
      end
    end
  end
end
