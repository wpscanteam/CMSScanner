# frozen_string_literal: true

shared_examples CMSScanner::References do
  describe '#references_keys' do
    it 'returns the expected array of symbols' do
      expect(subject.class.references_keys)
        .to eql %i[cve secunia osvdb exploitdb url metasploit packetstorm securityfocus]
    end
  end

  describe 'references' do
    context 'when no references' do
      %i[cves secunia_ids osvdb_ids exploitdb_ids urls
         msf_modules packetstorm_ids securityfocus_ids].each do |attribute|
        its(attribute) { should eql([]) }
      end

      %i[cve_urls secunia_urls osvdb_urls exploitdb_urls msf_urls
         packetstorm_urls secunia_urls].each do |attribute|
        its(attribute) { should eql([]) }
      end

      its(:references_urls) { should eql([]) }
    end

    context 'when an unknown reference key is provided' do
      let(:references) { { cve: 1, unknown: 12 } }

      its(:references) { should eql(cve: %w[1]) }
    end

    context 'when references provided as string' do
      let(:references) do
        {
          cve: 11,
          secunia: 12,
          osvdb: 13,
          exploitdb: 14,
          url: 'single-url',
          metasploit: '/exploit/yolo',
          packetstorm: 15,
          securityfocus: 16
        }
      end

      its(:cves)     { should eql %w[11] }
      its(:cve_urls) { should eql %w[https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11] }

      its(:secunia_ids)  { should eql %w[12] }
      its(:secunia_urls) { should eql %w[https://secuniaresearch.flexerasoftware.com/advisories/12/] }

      its(:osvdb_ids)  { should eql %w[13] }
      its(:osvdb_urls) { should eql %w[http://osvdb.org/show/osvdb/13] }

      its(:exploitdb_ids)  { should eql %w[14] }
      its(:exploitdb_urls) { should eql %w[https://www.exploit-db.com/exploits/14/] }

      its(:urls) { should eql %w[single-url] }

      its(:msf_modules) { should eql %w[/exploit/yolo] }
      its(:msf_urls) { should eql %w[https://www.rapid7.com/db/modules/exploit/yolo] }

      its(:packetstorm_ids)  { should eq %w[15] }
      its(:packetstorm_urls) { should eql %w[http://packetstormsecurity.com/files/15/] }

      its(:securityfocus_ids)  { should eq %w[16] }
      its(:securityfocus_urls) { should eql %w[http://www.securityfocus.com/bid/16/] }

      its(:references_urls) do
        should eql [
          'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11',
          'https://secuniaresearch.flexerasoftware.com/advisories/12/',
          'http://osvdb.org/show/osvdb/13',
          'https://www.exploit-db.com/exploits/14/',
          'single-url',
          'https://www.rapid7.com/db/modules/exploit/yolo',
          'http://packetstormsecurity.com/files/15/',
          'http://www.securityfocus.com/bid/16/'
        ]
      end
    end

    context 'when references provided as array' do
      let(:references) do
        {
          cve: [10, 11],
          secunia: [20, 21],
          osvdb: [30, 31],
          exploitdb: [40, 41],
          url: %w[single-url another-url],
          metasploit: %w[/exploit/yolo exploit/aa],
          packetstorm: [50, 51],
          securityfocus: [60, 61]
        }
      end

      its(:cves) { should eql %w[10 11] }
      its(:cve_urls) do
        should eql %w[https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-10
                      https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11]
      end

      its(:secunia_ids) { should eql %w[20 21] }
      its(:secunia_urls) do
        should eql %w[https://secuniaresearch.flexerasoftware.com/advisories/20/
                      https://secuniaresearch.flexerasoftware.com/advisories/21/]
      end

      its(:osvdb_ids) { should eql %w[30 31] }
      its(:osvdb_urls) do
        should eql %w[http://osvdb.org/show/osvdb/30
                      http://osvdb.org/show/osvdb/31]
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
        should eql %w[http://packetstormsecurity.com/files/50/
                      http://packetstormsecurity.com/files/51/]
      end

      its(:securityfocus_ids)  { should eq %w[60 61] }
      its(:securityfocus_urls) do
        should eql %w[http://www.securityfocus.com/bid/60/
                      http://www.securityfocus.com/bid/61/]
      end

      its(:references_urls) do
        should eql [
          'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-10',
          'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-11',
          'https://secuniaresearch.flexerasoftware.com/advisories/20/',
          'https://secuniaresearch.flexerasoftware.com/advisories/21/',
          'http://osvdb.org/show/osvdb/30',
          'http://osvdb.org/show/osvdb/31',
          'https://www.exploit-db.com/exploits/40/',
          'https://www.exploit-db.com/exploits/41/',
          'single-url',
          'another-url',
          'https://www.rapid7.com/db/modules/exploit/yolo',
          'https://www.rapid7.com/db/modules/exploit/aa',
          'http://packetstormsecurity.com/files/50/',
          'http://packetstormsecurity.com/files/51/',
          'http://www.securityfocus.com/bid/60/',
          'http://www.securityfocus.com/bid/61/'
        ]
      end
    end
  end
end
