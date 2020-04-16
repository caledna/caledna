# frozen_string_literal: true

require 'rails_helper'

describe ProcessEdnaResults do
  let(:dummy_class) { Class.new { extend ProcessEdnaResults } }

  describe '#convert_raw_barcode' do
    def subject(header)
      dummy_class.convert_raw_barcode(header)
    end

    it 'converts kit.number header' do
      header = 'X16S_K0078.C2.S59.L001'

      expect(subject(header)).to eq('K0078-LC-S2')
    end

    it 'converts K_L_S_ header' do
      headers = [
        ['X16S_K1LAS1.S18.L001', 'K0001-LA-S1'],
        ['X16S_K12LAS1.S18.L001', 'K0012-LA-S1'],
        ['X16S_K123LAS1.S18.L001', 'K0123-LA-S1'],
        ['X16S_K1234LAS1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts K_S_L_ header' do
      headers = [
        ['X16S_K1S1LA.S18.L001', 'K0001-LA-S1'],
        ['X16S_K12S1LA.S18.L001', 'K0012-LA-S1'],
        ['X16S_K123S1LA.S18.L001', 'K0123-LA-S1'],
        ['X16S_K1234S1LA.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts K_S_L_R_ header' do
      headers = [
        ['X16S_K1S1LAR1.S18.L001', 'K0001-LA-S1-R1'],
        ['X16S_K12S1LAR1.S18.L001', 'K0012-LA-S1-R1'],
        ['X16S_K123S1LAR1.S18.L001', 'K0123-LA-S1-R1'],
        ['X16S_K1234S1LAR1.S18.L001', 'K1234-LA-S1-R1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts K_LS header' do
      headers = [
        ['X16S_K1A1.S18.L001', 'K0001-LA-S1'],
        ['X16S_K12A1.S18.L001', 'K0012-LA-S1'],
        ['X16S_K123A1.S18.L001', 'K0123-LA-S1'],
        ['X16S_K1234A1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts _LS header' do
      headers = [
        ['X16S_1A1.S18.L001', 'K0001-LA-S1'],
        ['X16S_12A1.S18.L001', 'K0012-LA-S1'],
        ['X16S_123A1.S18.L001', 'K0123-LA-S1'],
        ['X16S_1234A1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts header without primers' do
      headers = [
        ['K1A1.S18.L001', 'K0001-LA-S1'],
        ['K12A1.S18.L001', 'K0012-LA-S1'],
        ['K123A1.S18.L001', 'K0123-LA-S1'],
        ['K1234A1.S18.L001', 'K1234-LA-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated K_LS header' do
      headers =  [
        ['K1B1', 'K0001-LB-S1'],
        ['K12B1', 'K0012-LB-S1'],
        ['K123B1', 'K0123-LB-S1'],
        ['K1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated X_LS header' do
      headers =  [
        ['X1B1', 'K0001-LB-S1'],
        ['X12B1', 'K0012-LB-S1'],
        ['X123B1', 'K0123-LB-S1'],
        ['X1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated _LS header' do
      headers =  [
        ['1B1', 'K0001-LB-S1'],
        ['12B1', 'K0012-LB-S1'],
        ['123B1', 'K0123-LB-S1'],
        ['1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts abbreviated PP_LS header' do
      headers =  [
        ['PP1B1', 'K0001-LB-S1'],
        ['PP12B1', 'K0012-LB-S1'],
        ['PP123B1', 'K0123-LB-S1'],
        ['PP1234B1', 'K1234-LB-S1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts X12S_K0723_A1.10.S10.L001' do
      headers = [
        ['X12S_K0001_A1.01.S01.L001', 'K0001-A1'],
        ['K0001_A1.01.S01.L001', 'K0001-A1']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'converts water samples' do
      headers = [
        ['X12S_MWWS_A0.01.S01.L001', 'MWWS-A0'],
        ['ASWS_A0.01.S01.L001', 'ASWS-A0']
      ]

      headers.each do |header|
        expect(subject(header.first)).to eq(header.second)
      end
    end

    it 'returns nil for "blank" samples' do
      headers = [
        'K0401.blank.S135.L001', 'X16s_K0001Blank.S1.L001', 'forestpcrBLANK',
        'X16S_ShrubBlank1'
      ]
      headers.each do |header|
        expect(subject(header)).to eq(nil)
      end
    end

    it 'returns nil for "neg" samples' do
      headers = [
        'K0401.extneg.S135.L001', 'X16s_K0001Neg.S1.L001', 'forestpcrNEG',
        'X16S_neg'
      ]

      headers.each do |header|
        expect(subject(header)).to eq(nil)
      end
    end

    it 'returns nil for invalid barcode' do
      header = 'PITS_forest.S96.L001'

      expect(subject(header)).to eq(nil)
    end
  end

  describe '#format_result_taxon_data_from_string' do
    def subject(string)
      dummy_class.format_result_taxon_data_from_string(string)
    end

    let(:id) { 100 }
    let(:ncbi_id) { 200 }
    let(:bold_id) { 300 }
    let(:ncbi_version_id) { create(:ncbi_version, id: 1).id }

    it 'foo' do
      string = 'Bacteria;Planctomycetes;Planctomycetia;Planctomycetales;Planctomycetaceae;Bythopirellula;'
      hierarchy = {
        superkingdom: 'Bacteria', phylum: 'Planctomycetes',
        class: 'Planctomycetia', order: 'Pirellulales',
        family: 'Lacipirellulaceae', genus: 'Bythopirellula'
      }
      create(:ncbi_node, canonical_name: 'Bythopirellula', rank: 'genus',
                         hierarchy_names: hierarchy, taxon_id: 1)
      results = subject(string)

      expect(results[:taxon_id]).to eq(1)
    end

    shared_examples_for 'all ranks are present' do |string, res_hierarchy|
      it 'returns a hash of taxon info when all ranks are present' do
        hierarchy_names = {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          order: 'Order',
          family: 'Family',
          genus: 'Genus',
          species: 'Species'
        }
        res_clean_string = dummy_class.remove_na(string)

        create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                           hierarchy_names: hierarchy_names, taxon_id: id,
                           ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)
        results = subject(string)

        expect(results[:original_taxonomy_string]).to eq(string)
        expect(results[:clean_taxonomy_string]).to eq(res_clean_string)
        expect(results[:taxon_id]).to eq(id)
        expect(results[:ncbi_id]).to eq(ncbi_id)
        expect(results[:bold_id]).to eq(bold_id)
        expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
        expect(results[:taxon_rank]).to eq('species')
        expect(results[:hierarchy]).to include(res_hierarchy)
      end
    end

    shared_examples_for 'there are missing ranks' do |string, res_hierarchy|
      it 'returns a hash of taxon info when there are missing ranks' do
        hierarchy_names = {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          order: 'Order',
          family: 'Family',
          genus: 'Genus'
        }
        res_clean_string = dummy_class.remove_na(string)

        create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                           hierarchy_names: hierarchy_names, taxon_id: id,
                           ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)
        results = subject(string)

        expect(results[:original_taxonomy_string]).to eq(string)
        expect(results[:clean_taxonomy_string]).to eq(res_clean_string)
        expect(results[:taxon_id]).to eq(id)
        expect(results[:ncbi_id]).to eq(ncbi_id)
        expect(results[:bold_id]).to eq(bold_id)
        expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
        expect(results[:taxon_rank]).to eq('genus')
        expect(results[:hierarchy]).to include(res_hierarchy)
      end
    end

    shared_examples_for 'there are NA ranks' do |string, res_hierarchy|
      it 'returns a hash of taxon info when there are NA ranks' do
        hierarchy_names = {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          class: 'Class',
          order: 'Order',
          genus: 'Genus'
        }
        res_clean_string = dummy_class.remove_na(string)

        create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                           hierarchy_names: hierarchy_names, taxon_id: id,
                           ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)
        results = subject(string)

        expect(results[:original_taxonomy_string]).to eq(string)
        expect(results[:clean_taxonomy_string]).to eq(res_clean_string)
        expect(results[:taxon_id]).to eq(id)
        expect(results[:ncbi_id]).to eq(ncbi_id)
        expect(results[:bold_id]).to eq(bold_id)
        expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
        expect(results[:taxon_rank]).to eq('genus')
        expect(results[:hierarchy]).to include(res_hierarchy)
      end
    end

    shared_examples_for 'if taxa not found' do |string, res_hierarchy|
      it 'returns a hash with nil taxon_id if taxa not found' do
        hierarchy_names = {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum2'
        }
        res_clean_string = dummy_class.remove_na(string)

        create(:ncbi_node, canonical_name: 'Phylum2', rank: 'phylum',
                           hierarchy_names: hierarchy_names, taxon_id: id,
                           ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)
        results = subject(string)

        expect(results[:original_taxonomy_string]).to eq(string)
        expect(results[:clean_taxonomy_string]).to eq(res_clean_string)
        expect(results[:taxon_id]).to eq(nil)
        expect(results[:ncbi_id]).to eq(nil)
        expect(results[:bold_id]).to eq(nil)
        expect(results[:ncbi_version_id]).to eq(nil)
        expect(results[:taxon_rank]).to eq('phylum')
        expect(results[:hierarchy]).to include(res_hierarchy)
      end
    end

    shared_examples_for 'multiple taxa are found' do |string, res_hierarchy|
      it 'returns a hash with nil taxon_id if multiple taxa are found' do
        hierarchy_names = {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: nil,
          class: 'Class',
          order: 'Order',
          genus: 'Genus',
          species: 'Species'
        }
        res_clean_string = dummy_class.remove_na(string)

        create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                           hierarchy_names:
                             hierarchy_names.merge(phylum: 'Phy1'),
                           taxon_id: 101, ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)
        create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                           hierarchy_names:
                             hierarchy_names.merge(phylum: 'Phy2'),
                           taxon_id: 102, ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)
        results = subject(string)

        expect(results[:original_taxonomy_string]).to eq(string)
        expect(results[:clean_taxonomy_string]).to eq(res_clean_string)
        expect(results[:taxon_id]).to eq(nil)
        expect(results[:ncbi_id]).to eq(nil)
        expect(results[:bold_id]).to eq(nil)
        expect(results[:ncbi_version_id]).to eq(nil)
        expect(results[:taxon_rank]).to eq('species')
        expect(results[:hierarchy]).to include(res_hierarchy)
      end
    end

    shared_examples_for 'string is all NA or ;;' do |string|
      it 'returns a hash of info if string is all NA or ;;' do
        results = subject(string)
        res_clean_string = dummy_class.remove_na(string)

        expect(results[:original_taxonomy_string]).to eq(string)
        expect(results[:clean_taxonomy_string]).to eq(res_clean_string)
        expect(results[:taxon_id]).to eq(nil)
        expect(results[:ncbi_id]).to eq(nil)
        expect(results[:bold_id]).to eq(nil)
        expect(results[:ncbi_version_id]).to eq(nil)
        expect(results[:taxon_rank]).to eq('unknown')
        expect(results[:hierarchy]).to eq({})
      end
    end

    shared_examples_for 'same name & superkingdom, diff phylum' do |str, hier|
      it 'distinguish between same name & superkingdom, different phylum' do
        hierarchy = { superkingdom: 'Superkingdom', phylum: 'Phylum1',
                      genus: 'Genus', species: 'Species' }
        hierarchy2 = { superkingdom: 'Superkingdom', phylum: 'Phylum2',
                       genus: 'Genus', species: 'Species' }
        clean_string = dummy_class.remove_na(str)

        create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                           hierarchy_names: hierarchy,
                           taxon_id: id, ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)

        create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                           hierarchy_names: hierarchy2,
                           taxon_id: 11, ncbi_id: 22,
                           bold_id: 33,
                           ncbi_version_id: ncbi_version_id)
        results = subject(str)

        expect(results[:original_taxonomy_string]).to eq(str)
        expect(results[:clean_taxonomy_string]).to eq(clean_string)
        expect(results[:taxon_id]).to eq(id)
        expect(results[:ncbi_id]).to eq(ncbi_id)
        expect(results[:bold_id]).to eq(bold_id)
        expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
        expect(results[:taxon_rank]).to eq('species')
        expect(results[:hierarchy]).to eq(hier)
      end
    end

    it 'returns a hash of info if string is NA' do
      results = subject('NA')

      expect(results[:original_taxonomy_string]).to eq('NA')
      expect(results[:clean_taxonomy_string]).to eq('NA')
      expect(results[:taxon_id]).to eq(nil)
      expect(results[:ncbi_id]).to eq(nil)
      expect(results[:bold_id]).to eq(nil)
      expect(results[:ncbi_version_id]).to eq(nil)
      expect(results[:taxon_rank]).to eq('unknown')
      expect(results[:hierarchy]).to eq({})
    end

    context 'When there is a phylum string' do
      string = 'NA;;NA;;NA;'
      it_behaves_like 'string is all NA or ;;', string

      string = 'Phylum;Class;Order;Family;Genus;Species'
      hierarchy = { phylum: 'Phylum', class: 'Class', order: 'Order',
                    family: 'Family', genus: 'Genus', species: 'Species' }
      it_behaves_like 'all ranks are present', string, hierarchy

      string = ';Class;Order;;Genus;'
      hierarchy = { class: 'Class', order: 'Order', genus: 'Genus' }
      it_behaves_like 'there are missing ranks', string, hierarchy

      string = 'NA;Class;Order;NA;Genus;'
      hierarchy = { class: 'Class', order: 'Order', genus: 'Genus' }
      it_behaves_like 'there are NA ranks', string, hierarchy

      string = 'Phylum;NA;;;;'
      hierarchy = { phylum: 'Phylum' }
      it_behaves_like 'if taxa not found', string, hierarchy

      string = 'NA;Class;Order;;Genus;Species'
      hierarchy = { genus: 'Genus', order: 'Order', class: 'Class',
                    species: 'Species' }
      it_behaves_like 'multiple taxa are found', string, hierarchy

      string = 'Phylum1;;;;Genus;Species'
      hierarchy = { phylum: 'Phylum1', genus: 'Genus', species: 'Species' }
      it_behaves_like 'same name & superkingdom, diff phylum', string, hierarchy
    end

    context 'When there is a superkingdom string' do
      string = ';NA;;NA;;NA;'
      it_behaves_like 'string is all NA or ;;', string

      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
      hierarchy = { phylum: 'Phylum', class: 'Class', order: 'Order',
                    family: 'Family', genus: 'Genus', species: 'Species',
                    superkingdom: 'Superkingdom' }
      it_behaves_like 'all ranks are present', string, hierarchy

      string = ';;Class;Order;;Genus;'
      hierarchy = { class: 'Class', order: 'Order', genus: 'Genus' }
      it_behaves_like 'there are missing ranks', string, hierarchy

      string = 'NA;NA;Class;Order;NA;Genus;'
      hierarchy = { class: 'Class', order: 'Order', genus: 'Genus' }
      it_behaves_like 'there are NA ranks', string, hierarchy

      string = 'Superkingdom;Phylum;NA;;;;'
      hierarchy = { phylum: 'Phylum', superkingdom: 'Superkingdom' }
      it_behaves_like 'if taxa not found', string, hierarchy

      string = ';NA;Class;Order;;Genus;Species'
      hierarchy = { genus: 'Genus', order: 'Order', class: 'Class',
                    species: 'Species' }
      it_behaves_like 'multiple taxa are found', string, hierarchy

      string = 'Superkingdom;Phylum1;;;;Genus;Species'
      hierarchy = { superkingdom: 'Superkingdom', phylum: 'Phylum1',
                    genus: 'Genus', species: 'Species' }
      it_behaves_like 'same name & superkingdom, diff phylum', string, hierarchy

      it 'distinguish between taxa with same name but different superkingdom' do
        string = 'Superkingdom1;;;;;Genus;Species'
        hierarchy = { superkingdom: 'Superkingdom1',
                      genus: 'Genus', species: 'Species' }
        hierarchy2 = { superkingdom: 'Superkingdom2',
                       genus: 'Genus', species: 'Species' }
        clean_string = dummy_class.remove_na(string)

        create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                           hierarchy_names: hierarchy,
                           taxon_id: id, ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)

        create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                           hierarchy_names: hierarchy2,
                           taxon_id: 11, ncbi_id: 22,
                           bold_id: 33,
                           ncbi_version_id: ncbi_version_id)
        results = subject(string)

        expect(results[:original_taxonomy_string]).to eq(string)
        expect(results[:clean_taxonomy_string]).to eq(clean_string)
        expect(results[:taxon_id]).to eq(id)
        expect(results[:ncbi_id]).to eq(ncbi_id)
        expect(results[:bold_id]).to eq(bold_id)
        expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
        expect(results[:taxon_rank]).to eq('species')
        expect(results[:hierarchy]).to eq(superkingdom: 'Superkingdom1',
                                          species: 'Species',
                                          genus: 'Genus')
      end
    end
  end

  describe '#invalid_taxon?' do
    def subject(string)
      dummy_class.invalid_taxon?(string)
    end

    it 'returns true if string is "NA"' do
      string = 'NA'

      expect(subject(string)).to eq(true)
    end

    it 'returns true if string is all semicolons' do
      strings = [';;;;;;', ';;;;;']

      strings.each do |string|
        expect(subject(string)).to eq(true)
      end
    end

    it 'returns true if string has too many parts' do
      string = 's;p;c;o;f;g;s;x'

      expect(subject(string)).to eq(true)
    end

    it 'returns true if string has too few parts' do
      string = 'p;c;o;f;g'

      expect(subject(string)).to eq(true)
    end

    it 'returns true if empty string' do
      string = ''

      expect(subject(string)).to eq(true)
    end

    it 'returns true if string is only "NA" and semicolons' do
      strings = [';NA;;;;;', ';NA;;NA;;NA;', ';;;;;;NA', 'NA;;;;;']

      strings.each do |string|
        expect(subject(string)).to eq(true)
      end
    end

    it 'returns false otherwise' do
      strings = [
        'p;c;o;f;g;s', 'p;;;;;', ';;;;;s',
        'sk;p;c;o;f;g;s', 'sk;;;;;;', ';;;;;;s', 'sk;NA;;NA;;NA;'
      ]

      strings.each do |string|
        expect(subject(string)).to eq(false)
      end
    end
  end

  describe '#get_taxon_rank_phylum' do
    def subject(string)
      dummy_class.get_taxon_rank_phylum(string)
    end

    it 'returns species if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns species if only species exists' do
      string = ';;;;;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns genus if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;'
      expect(subject(string)).to eq('genus')
    end

    it 'returns family if it exists' do
      string = 'Phylum;Class;Order;Family;;'
      expect(subject(string)).to eq('family')
    end

    it 'returns order if it exists' do
      string = 'Phylum;Class;Order;;;'
      expect(subject(string)).to eq('order')
    end

    it 'returns class if it exists' do
      string = 'Phylum;Class;;;;'
      expect(subject(string)).to eq('class')
    end

    it 'returns phylum if it exists' do
      string = 'Phylum;;;;;'
      expect(subject(string)).to eq('phylum')
    end

    it 'ignores "NA"' do
      string = 'Phylum;Class;Order;Family;NA;NA'
      expect(subject(string)).to eq('family')
    end

    it 'retuns "unknown" when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq('unknown')
    end

    it 'retuns "unknown" when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq('unknown')
    end
  end

  describe '#get_hierarchy_phylum' do
    def subject(string)
      dummy_class.get_hierarchy_phylum(string)
    end

    it 'returns taxon data when taxon has long hierarchy names' do
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        subphylum: 'Subphylum',
        class: 'Class',
        subclass: 'Subclass',
        superorder: 'Superorder',
        order: 'Order',
        suborder: 'Suborder',
        infraorder: 'Infraorder',
        superfamily: 'Superfamily',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }
      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names)
      string = 'Phylum;Class;Order;Family;Genus;'

      expect(subject(string)).to eq(
        phylum: 'Phylum', class: 'Class', order: 'Order', family: 'Family',
        genus: 'Genus'
      )
    end

    it 'returns a hash of taxonomy names' do
      create(
        :ncbi_node,
        canonical_name: 'Species',
        rank: 'species',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          order: 'Order',
          family: 'Family',
          genus: 'Genus',
          species: 'Species'
        }
      )
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expected = {
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain missing taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Phylum;Class;;Family;Genus;'
      expected = {
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain "NA" taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Phylum;Class;NA;Family;Genus;NA'
      expected = {
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq({})
    end
  end

  describe '#get_taxon_rank_superkingdom' do
    def subject(string)
      dummy_class.get_taxon_rank_superkingdom(string)
    end

    it 'returns species if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns species if only species exists' do
      string = ';;;;;;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns genus if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;'
      expect(subject(string)).to eq('genus')
    end

    it 'returns family if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;Family;;'
      expect(subject(string)).to eq('family')
    end

    it 'returns order if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;;;'
      expect(subject(string)).to eq('order')
    end

    it 'returns class if it exists' do
      string = 'Superkingdom;Phylum;Class;;;;'
      expect(subject(string)).to eq('class')
    end

    it 'returns phylum if it exists' do
      string = 'Superkingdom;Phylum;;;;;'
      expect(subject(string)).to eq('phylum')
    end

    it 'returns superkingdom if it exists' do
      string = 'Superkingdom;;;;;;'
      expect(subject(string)).to eq('superkingdom')
    end

    it 'ignores "NA"' do
      string = 'Superkingdom;Phylum;Class;Order;Family;NA;NA'
      expect(subject(string)).to eq('family')
    end

    it 'retuns "unknown" when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq('unknown')
    end

    it 'retuns "unknown" when entire string is ";;;;;;"' do
      string = ';;;;;;'
      expect(subject(string)).to eq('unknown')
    end
  end

  describe '#get_hierarchy_superkingdom' do
    def subject(string)
      dummy_class.get_hierarchy_superkingdom(string)
    end

    it 'returns taxon data when taxon has long hierarchy names' do
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        subphylum: 'Subphylum',
        class: 'Class',
        subclass: 'Subclass',
        superorder: 'Superorder',
        order: 'Order',
        suborder: 'Suborder',
        infraorder: 'Infraorder',
        superfamily: 'Superfamily',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }
      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names)
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;'

      expect(subject(string)).to eq(
        superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus'
      )
    end

    it 'returns a hash of taxonomy names' do
      create(
        :ncbi_node,
        canonical_name: 'Species',
        rank: 'species',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          order: 'Order',
          family: 'Family',
          genus: 'Genus',
          species: 'Species'
        }
      )
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
      expected = {
        superkingdom: 'Superkingdom',
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain missing taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Superkingdom;Phylum;Class;;Family;Genus;'
      expected = {
        superkingdom: 'Superkingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain "NA" taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Superkingdom;Phylum;Class;NA;Family;Genus;NA'
      expected = {
        superkingdom: 'Superkingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;"' do
      string = ';;;;;;'
      expect(subject(string)).to eq({})
    end
  end

  describe '#find_taxa_by_hierarchy' do
    def subject(hierarchy, rank)
      dummy_class.find_taxa_by_hierarchy(hierarchy, rank)
    end

    shared_examples_for 'hierarchy and rank exactly match' do |hierarchy, rank|
      it 'returns matching taxa' do
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank)

        expect(subject(hierarchy, rank)).to eq([taxa])
      end
    end

    shared_examples_for 'phylum and lowest rank match' do |given_h, hier, rank|
      it 'returns matching taxa' do
        taxa = create(:ncbi_node, hierarchy_names: hier, rank: rank)

        expect(subject(given_h, rank)).to match_array([taxa])
      end
    end

    context 'when a given hierarchy and rank exactly match an existing taxa' do
      hierarchy = { superkingdom: 'Superkingdom' }
      rank = 'superkingdom'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = { superkingdom: 'Superkingdom', kingdom: 'Kingdom' }
      rank = 'kingdom'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', phylum: 'Phylum'
      }
      rank = 'phylum'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', phylum: 'Phylum',
        class: 'Class'
      }
      rank = 'class'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', phylum: 'Phylum',
        class: 'Class', order: 'Order'
      }
      rank = 'order'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', phylum: 'Phylum',
        class: 'Class', order: 'Order', family: 'Family'
      }
      rank = 'family'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', phylum: 'Phylum',
        class: 'Class', order: 'Order', family: 'Family', genus: 'Genus'
      }
      rank = 'genus'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', phylum: 'Phylum',
        class: 'Class', order: 'Order', family: 'Family', genus: 'Genus',
        species: 'Species'
      }
      rank = 'species'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      it 'returns matching taxa for incomplete hierarchy' do
        hierarchy = {
          genus: 'Genus', species: 'Species'
        }
        rank = 'species'
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank)

        expect(subject(hierarchy, rank)).to eq([taxa])
      end

      it 'returns matching taxa when name has single quotes' do
        hierarchy = {
          genus: 'Genus', species: "Species 'name'"
        }
        rank = 'species'
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank)

        expect(subject(hierarchy, rank)).to eq([taxa])
      end
    end

    context 'when a given hierarchy match, but rank does not match an ' \
      'existing taxa' do
      it 'returns empty array' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom'
        }
        rank1 = 'kingdom'
        rank2 = 'no rank'
        create(:ncbi_node, hierarchy_names: hierarchy, rank: rank2)

        expect(subject(hierarchy, rank1)).to eq([])
      end
    end

    context 'when a given hierarchy does not match, but rank does match an ' \
    'existing taxa' do
      it 'returns empty array' do
        hierarchy1 = {
          superkingdom: 'Superkingdom', phylum: 'Phylum 1'
        }
        hierarchy2 = {
          superkingdom: 'Superkingdom', phylum: 'Phylum 2'
        }
        rank = 'phylum'
        create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank)

        expect(subject(hierarchy1, rank)).to eq([])
      end
    end

    context 'when hierarchy partially match and rank match an existing taxa' do
      it 'returns all matching taxa' do
        given_hierarchy = {
          class: 'Class', family: 'Family'
        }
        hierarchy1 = given_hierarchy.merge(phylum: 'Phylum1')
        hierarchy2 = given_hierarchy.merge(phylum: 'Phylum2')
        rank = 'family'
        taxa1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank)
        taxa2 = create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank)

        expect(subject(given_hierarchy, rank)).to match_array([taxa1, taxa2])
      end
    end

    context 'when hierarchy partially match and rank does not match an ' \
      'existing taxa' do
      it 'returns empty array' do
        given_hierarchy = {
          class: 'Class', family: 'Family'
        }
        given_rank = 'no rank'

        hierarchy = given_hierarchy.merge(phylum: 'Phylum1')
        rank = 'family'
        create(:ncbi_node, hierarchy_names: hierarchy, rank: rank)

        expect(subject(given_hierarchy, given_rank)).to match_array([])
      end
    end

    context 'when given superkingdom and lowest rank match, but middle ' \
      'taxa do not match an existing taxa' do
      given_hier = {
        superkingdom: 'sk', kingdom: 'k',
        class: 'c'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k2',
        class: 'c'
      }
      rank = 'class'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      given_hier = {
        superkingdom: 'sk', kingdom: 'k',
        class: 'c', order: 'o'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k2',
        class: 'c2', order: 'o'
      }
      rank = 'order'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      given_hier = {
        superkingdom: 'sk', kingdom: 'k',
        class: 'c', order: 'o', family: 'f'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k2',
        class: 'c2', order: 'o2', family: 'f'
      }
      rank = 'family'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      given_hier = {
        superkingdom: 'sk', kingdom: 'k',
        class: 'c', order: 'o', genus: 'g'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k2',
        class: 'c2', order: 'o2', genus: 'g'
      }
      rank = 'genus'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      given_hier = {
        superkingdom: 'sk', kingdom: 'k',
        class: 'c', order: 'o', family: 'f', genus: 'g', species: 'sp'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k2',
        class: 'c2', order: 'o2', family: 'f2', genus: 'g2', species: 'sp'
      }
      rank = 'species'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      context ', and family and genus match, and rank is genus' do
        given_hier = {
          superkingdom: 'sk', kingdom: 'k',
          class: 'c', order: 'o', family: 'f', genus: 'g'
        }
        hier = {
          superkingdom: 'sk', kingdom: 'k2',
          class: 'c2', order: 'o2', family: 'f', genus: 'g'
        }
        rank = 'genus'
        it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank
      end

      context ', and family do not match, genus match, and rank is genus' do
        given_hier = {
          superkingdom: 'sk', kingdom: 'k',
          class: 'c', order: 'o', family: 'f', genus: 'g'
        }
        hier = {
          superkingdom: 'sk', kingdom: 'k2',
          class: 'c2', order: 'o2', family: 'f2', genus: 'g'
        }
        rank = 'genus'
        it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank
      end
    end

    context 'when given phylum and lowest rank match, but middle taxa do not' \
      'match an existing taxa' do
      given_hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c', order: 'o'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c2', order: 'o'
      }
      rank = 'order'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      given_hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c', order: 'o', family: 'f'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c2', order: 'o2', family: 'f'
      }
      rank = 'family'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      given_hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c', order: 'o', genus: 'g'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c2', order: 'o2', genus: 'g'
      }
      rank = 'genus'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      given_hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c', order: 'o', family: 'f', genus: 'g', species: 'sp'
      }
      hier = {
        superkingdom: 'sk', kingdom: 'k', phylum: 'p',
        class: 'c2', order: 'o2', family: 'f2', genus: 'g2', species: 'sp'
      }
      rank = 'species'
      it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank

      context ', and family and genus match, and rank is genus' do
        given_hier = {
          superkingdom: 'sk', kingdom: 'k', phylum: 'p',
          class: 'c', order: 'o', family: 'f', genus: 'g'
        }
        hier = {
          superkingdom: 'sk', kingdom: 'k', phylum: 'p',
          class: 'c2', order: 'o2', family: 'f', genus: 'g'
        }
        rank = 'genus'
        it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank
      end

      context ', and family do not match, genus match, and rank is genus' do
        given_hier = {
          superkingdom: 'sk', kingdom: 'k', phylum: 'p',
          class: 'c', order: 'o', family: 'f', genus: 'g'
        }
        hier = {
          superkingdom: 'sk', kingdom: 'k', phylum: 'p',
          class: 'c2', order: 'o2', family: 'f2', genus: 'g'
        }
        rank = 'genus'
        it_behaves_like 'phylum and lowest rank match', given_hier, hier, rank
      end
    end
  end

  describe '#filtered_hierarchy' do
    def subject(hierarchy, rank, include_family=false)
      dummy_class.filtered_hierarchy(hierarchy, rank, include_family)
    end

    context 'for ranks superkingdom and lower, when superkingdom is present' \
      'and phylum is absent ' do
      it 'returns a hierarchy with superkingdom and a given rank' do
        hierarchy = { superkingdom: 'sk' }
        expect(subject(hierarchy, 'superkingdom')).to eq(superkingdom: 'sk')

        hierarchy = { superkingdom: 'sk', kingdom: 'k' }
        expect(subject(hierarchy, 'kingdom'))
          .to eq(superkingdom: 'sk', kingdom: 'k')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', class: 'c' }
        expect(subject(hierarchy, 'class'))
          .to eq(superkingdom: 'sk', class: 'c')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', class: 'c', order: 'o' }
        expect(subject(hierarchy, 'order'))
          .to eq(superkingdom: 'sk', order: 'o')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', class: 'c', order: 'o',
                      family: 'f' }
        expect(subject(hierarchy, 'family'))
          .to eq(superkingdom: 'sk', family: 'f')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', class: 'c', order: 'o',
                      genus: 'g' }
        expect(subject(hierarchy, 'genus'))
          .to eq(superkingdom: 'sk', genus: 'g')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', class: 'c', order: 'o',
                      family: 'f', genus: 'g', species: 's' }
        expect(subject(hierarchy, 'species'))
          .to eq(superkingdom: 'sk', species: 's')
      end
    end

    context 'for ranks phylum and lower, when superkingdom and phylum are ' \
      'present' do
      it 'returns a hierarchy with phylum and a given rank' do
        hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p' }
        expect(subject(hierarchy, 'phylum')).to eq(phylum: 'p')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p',
                      class: 'c' }
        expect(subject(hierarchy, 'class')).to eq(phylum: 'p', class: 'c')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p', class: 'c',
                      order: 'o' }
        expect(subject(hierarchy, 'order')).to eq(phylum: 'p', order: 'o')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p', class: 'c',
                      order: 'o',  family: 'f' }
        expect(subject(hierarchy, 'family')).to eq(phylum: 'p', family: 'f')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p', class: 'c',
                      order: 'o', genus: 'g' }
        expect(subject(hierarchy, 'genus')).to eq(phylum: 'p', genus: 'g')

        hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p', class: 'c',
                      order: 'o', family: 'f', genus: 'g', species: 's' }
        expect(subject(hierarchy, 'species')).to eq(phylum: 'p', species: 's')
      end
    end

    context 'for ranks kingdom and lower, when superkingdom is absent and ' \
      'phylum is present' do
      it 'returns a hierarchy with phylum and a given rank' do
        hierarchy = { kingdom: 'k', phylum: 'p' }
        expect(subject(hierarchy, 'phylum')).to eq(phylum: 'p')

        hierarchy = { kingdom: 'k', phylum: 'p', class: 'c' }
        expect(subject(hierarchy, 'class')).to eq(phylum: 'p', class: 'c')

        hierarchy = { kingdom: 'k', phylum: 'p', class: 'c', order: 'o' }
        expect(subject(hierarchy, 'order')).to eq(phylum: 'p', order: 'o')

        hierarchy = { kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
                      family: 'f' }
        expect(subject(hierarchy, 'family')).to eq(phylum: 'p', family: 'f')

        hierarchy = { kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
                      genus: 'g' }
        expect(subject(hierarchy, 'genus')).to eq(phylum: 'p', genus: 'g')

        hierarchy = { kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
                      family: 'f', genus: 'g', species: 's' }
        expect(subject(hierarchy, 'species')).to eq(phylum: 'p', species: 's')
      end
    end

    context 'for ranks kingdom and lower, when superkingdom and phylum ' \
      'are absent' do
      it 'returns a hierarchy with a given rank' do
        hierarchy = { kingdom: 'k' }
        expect(subject(hierarchy, 'kingdom')).to eq(kingdom: 'k')

        hierarchy = { kingdom: 'k', class: 'c' }
        expect(subject(hierarchy, 'class')).to eq(class: 'c')

        hierarchy = { kingdom: 'k', class: 'c', order: 'o' }
        expect(subject(hierarchy, 'order')).to eq(order: 'o')

        hierarchy = { kingdom: 'k', class: 'c', order: 'o', family: 'f' }
        expect(subject(hierarchy, 'family')).to eq(family: 'f')

        hierarchy = { kingdom: 'k', class: 'c', order: 'o', genus: 'g' }
        expect(subject(hierarchy, 'genus')).to eq(genus: 'g')

        hierarchy = { kingdom: 'k', class: 'c', order: 'o',
                      family: 'f', genus: 'g', species: 's' }
        expect(subject(hierarchy, 'species')).to eq(species: 's')
      end
    end

    context 'for rank genus, when family and genus are present, ' do
      context 'and include_family is true' do
        let(:include_family) { true }
        context 'superkingdom is present and phylum is absent ' do
          it 'returns a phlyum, family, genus' do
            hierarchy = { superkingdom: 'sk', kingdom: 'k', class: 'c',
                          order: 'o', family: 'f', genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(superkingdom: 'sk', family: 'f', genus: 'g')
          end
        end

        context 'superkingdom and phylum are present' do
          it 'returns a phlyum, family, genus' do
            hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p',
                          class: 'c', order: 'o', family: 'f', genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(phylum: 'p', family: 'f', genus: 'g')
          end
        end

        context 'superkingdom is absent and phylum is present ' do
          it 'returns a phlyum, family, genus' do
            hierarchy = { kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
                          family: 'f', genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(phylum: 'p', family: 'f', genus: 'g')
          end
        end

        context 'superkingdom and phylum are absent' do
          it 'returns a family, genus' do
            hierarchy = { kingdom: 'k', class: 'c', order: 'o', family: 'f',
                          genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(family: 'f', genus: 'g')
          end
        end


      end

      context 'and include_family is false' do
        let(:include_family) { false }
        context 'superkingdom is present and phylum is absent ' do
          it 'returns a phlyum, family, genus' do
            hierarchy = { superkingdom: 'sk', kingdom: 'k', class: 'c',
                          order: 'o', family: 'f', genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(superkingdom: 'sk', genus: 'g')
          end
        end

        context 'superkingdom and phylum are present' do
          it 'returns a phlyum, family, genus' do
            hierarchy = { superkingdom: 'sk', kingdom: 'k', phylum: 'p',
                          class: 'c', order: 'o', family: 'f', genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(phylum: 'p', genus: 'g')
          end
        end

        context 'superkingdom is absent and phylum is present ' do
          it 'returns a phlyum, family, genus' do
            hierarchy = { kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
                          family: 'f', genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(phylum: 'p', genus: 'g')
          end
        end

        context 'superkingdom and phylum are absent' do
          it 'returns a family, genus' do
            hierarchy = { kingdom: 'k', class: 'c', order: 'o', family: 'f',
                          genus: 'g' }
            expect(subject(hierarchy, 'genus', include_family))
              .to eq(genus: 'g')
          end
        end
      end
    end
  end

  describe '#find_sample_from_barcode' do
    let(:barcode) { 'K0001-LA-S1' }
    let(:project) { create(:field_project, name: 'unknown') }
    let(:status) { :approved }

    def subject
      dummy_class.find_sample_from_barcode(barcode, status)
    end

    context 'there are no samples for a given bar code' do
      it 'creates a new sample' do
        stub_const('FieldProject::DEFAULT_PROJECT', project)

        expect { subject }.to change { Sample.count }.by(1)
      end

      it 'returns the created sample' do
        stub_const('FieldProject::DEFAULT_PROJECT', project)
        result = subject

        expect(result.barcode).to eq(barcode)
        expect(result.field_project).to eq(project)
        expect(result.missing_coordinates).to eq(true)
        expect(result.status).to eq(status)
      end
    end

    context 'there is one valid sample for a given barcode' do
      it 'returns the matching sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status' do
        create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result.status).to eq(status)
      end
    end

    context 'there is one valid and one invalid sample for a given barcode' do
      it 'returns the matching  valid sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result.status).to eq(status)
      end
    end

    context 'there are multiple valid samples for a given barcode' do
      it 'raises an error' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :results_completed, barcode: barcode)

        message = /multiple samples with barcode/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end

    context 'all samples are rejected for a given barcode' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :rejected, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end

    context 'all samples are duplicate_barcode for a given bar code' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end
  end

  describe '#form_barcode' do
    def subject(string)
      dummy_class.form_barcode(string)
    end

    it 'returns a barcode when given a valid kit number with spaces' do
      string = 'K0001 B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'returns a barcode when given a valid kit number w/o spaces' do
      string = 'K0001B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'otherwise returns the original string' do
      string = 'abc'

      expect(subject(string)).to eq(string)
    end
  end

  describe '#phylum_taxonomy_string?' do
    def subject(string)
      dummy_class.phylum_taxonomy_string?(string)
    end

    it 'returns true when taxonomy string has 6 taxa' do
      string = 'phylum;class;order;family;genus;species'

      expect(subject(string)).to eq(true)
    end

    it 'returns correct results with "NA"' do
      string = 'NA;NA;order;NA;genus;species'

      expect(subject(string)).to eq(true)
    end

    it 'returns correct results with ";"' do
      string = ';;order;;genus;species'

      expect(subject(string)).to eq(true)
    end

    it 'returns false when taxonomy string has 7 taxa' do
      string = 'superkingdom;phylum;class;order;family;genus;species'

      expect(subject(string)).to eq(false)
    end

    it 'correctly analyzes phlyum string when taxa is missing' do
      string = ';class;order;family;;'

      expect(subject(string)).to eq(true)
    end

    it 'correctly analyzes superkingdom string when taxa is missing' do
      string = ';phylum;class;order;family;genus;'

      expect(subject(string)).to eq(false)
    end

    it 'correctly analyzes phlyum string when not taxa' do
      string = ';;;;;'

      expect(subject(string)).to eq(true)
    end

    it 'correctly analyzes superkingdom string when no taxa' do
      string = ';;;;;;'

      expect(subject(string)).to eq(false)
    end

    it 'correctly counts missing taxa for superkingdoms' do
      string = ';phylum;class;order;family;genus;'

      expect(subject(string)).to eq(false)
    end

    it 'it raise an error when there are invalid number of taxa' do
      string = 'random;string;will;fail'

      message = /invalid taxonomy string/
      expect { subject(string) }.to raise_error(TaxaError, message)
    end
  end

  describe '#find_canonical_taxon_from_string' do
    def subject(string)
      dummy_class.find_canonical_taxon_from_string(string)
    end

    it 'returns species if it exists' do
      string = 'superkingdom;phlyum;class;order;family;genus;species'

      expect(subject(string)).to eq('species')
    end

    it 'returns genus if it exists' do
      string = 'superkingdom;phlyum;class;order;family;genus;'

      expect(subject(string)).to eq('genus')
    end

    it 'returns family if it exists' do
      string = 'superkingdom;phlyum;class;order;family;;'

      expect(subject(string)).to eq('family')
    end

    it 'returns order if it exists' do
      string = 'superkingdom;phlyum;class;order;;;'

      expect(subject(string)).to eq('order')
    end

    it 'returns class if it exists' do
      string = 'superkingdom;phlyum;class;;;;'

      expect(subject(string)).to eq('class')
    end

    it 'returns phlyum if it exists' do
      string = 'superkingdom;phlyum;;;;;'

      expect(subject(string)).to eq('phlyum')
    end

    it 'returns superkingdom if it exists' do
      string = 'superkingdom;;;;;;'

      expect(subject(string)).to eq('superkingdom')
    end

    it 'ignores species NA' do
      string = 'superkingdom;phlyum;class;order;family;genus;NA'

      expect(subject(string)).to eq('genus')
    end

    it 'ignores genus NA' do
      string = 'superkingdom;phlyum;class;order;family;NA;NA'

      expect(subject(string)).to eq('family')
    end

    it 'ignores family NA' do
      string = 'superkingdom;phlyum;class;order;NA;NA;NA'

      expect(subject(string)).to eq('order')
    end

    it 'ignores order NA' do
      string = 'superkingdom;phlyum;class;NA;NA;NA;NA'

      expect(subject(string)).to eq('class')
    end

    it 'ignores class NA' do
      string = 'superkingdom;phlyum;NA;NA;NA;NA;NA'

      expect(subject(string)).to eq('phlyum')
    end

    it 'ignores phylum NA' do
      string = 'superkingdom;NA;NA;NA;NA;NA;NA'

      expect(subject(string)).to eq('superkingdom')
    end

    it 'returns NA if string is NA' do
      string = 'NA'

      expect(subject(string)).to eq('NA')
    end

    it 'returns semicolons if string is combination of NA and ;;' do
      string = 'NA;;NA;NA;;;NA'

      expect(subject(string)).to eq(';;;;;;')
    end
  end

  describe '#remove_na' do
    def subject(string)
      dummy_class.remove_na(string)
    end

    it 'removes beginning NA' do
      string = 'NA;NA;b;NA;c'
      expect(subject(string)).to eq(';;b;;c')
    end

    it 'removes middle NA' do
      string = 'a;NA;b;NA;c'
      expect(subject(string)).to eq('a;;b;;c')
    end

    it 'removes ending NA' do
      string = 'a;NA;b;NA;NA'

      expect(subject(string)).to eq('a;;b;;')
    end

    it 'removes consecutive NA' do
      string = 'a;NA;NA;NA;c'
      expect(subject(string)).to eq('a;;;;c')
    end

    it 'does not change string' do
      string = 'a;NA;NA;NA;c'
      new_string = subject(string)

      expect(new_string).to eq('a;;;;c')
      expect(string).to eq(string)
    end
  end

  describe '#find_result_taxon_from_string' do
    def subject(string)
      dummy_class.find_result_taxon_from_string(string)
    end

    def clean_string(string)
      dummy_class.remove_na(string)
    end

    context 'phylum taxonomy string' do
      it 'handles complete taxonomy strings and returns matching ResultTaxon' do
        taxonomy_string = 'Phylum;Class;Order;Family;Genus;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles blank ranks and returns matching ResultTaxon' do
        taxonomy_string = 'Phylum;;Order;Family;;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles NA and returns matching ResultTaxon' do
        taxonomy_string = 'NA;NA;Order;Family;NA;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'taxonomy string with same cleaned string returns same ResultTaxon' do
        taxonomy_string1 = 'Phylum;NA;Order;;;'
        taxonomy_string2 = 'Phylum;;Order;;;'
        taxonomy_string3 = 'Phylum;NA;Order;NA;NA;'
        taxonomy_string4 = ';Order;;;;'
        clean_string = 'Phylum;;Order;;;'
        rank = 'order'

        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)
        expect(subject(taxonomy_string1)).to eq(taxa)
        expect(subject(taxonomy_string2)).to eq(taxa)
        expect(subject(taxonomy_string3)).to eq(taxa)
        expect(subject(taxonomy_string4)).to eq(nil)
      end
    end

    context 'superkingdom taxonomy string' do
      it 'handles complete taxonomy strings and returns matching ResultTaxon' do
        taxonomy_string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles blank ranks and returns matching ResultTaxon' do
        taxonomy_string = ';Phylum;;Order;Family;;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles NA and returns matching ResultTaxon' do
        taxonomy_string = 'NA;NA;;Order;Family;NA;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end
    end
  end

  describe '#process_barcodes_for_csv_table' do
    def subject(csv_data)
      dummy_class.process_barcodes_for_csv_table(csv_data, 'barcode')
    end

    let(:csv) { './spec/fixtures/import_csv/samples.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:csv_data) do
      delimiter = ';'
      CSV.read(file.path, headers: true, col_sep: delimiter)
    end
    let(:barcode1) { 'K9999-A1' }
    let(:barcode2) { 'K9999-A2' }

    context 'when csv data has mix of existing and new barcodes' do
      it 'returns hash of existing and new barcodes' do
        create(:sample, barcode: barcode1)
        expected = { existing_barcodes: [barcode1], new_barcodes: [barcode2] }

        expect(subject(csv_data)).to eq(expected)
      end
    end

    context 'when csv data only has existing barcodes' do
      it 'returns hash of existing barcodes' do
        create(:sample, barcode: barcode1)
        create(:sample, barcode: barcode2)
        expected = { existing_barcodes: [barcode1, barcode2], new_barcodes: [] }

        expect(subject(csv_data)).to eq(expected)
      end
    end

    context 'when csv data only has new barcodes' do
      it 'returns hash of new barcodes' do
        expected = { existing_barcodes: [], new_barcodes: [barcode1, barcode2] }

        expect(subject(csv_data)).to eq(expected)
      end
    end
  end
end
