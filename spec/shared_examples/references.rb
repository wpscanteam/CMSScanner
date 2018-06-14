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
      its(:secunia_urls) { should eql %w[https://secunia.com/advisories/12/] }

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
          'https://secunia.com/advisories/12/',
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
      xit
    end
  end
end
