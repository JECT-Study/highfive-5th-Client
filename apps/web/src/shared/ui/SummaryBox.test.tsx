import { cleanup, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';
import { SummaryBox } from './SummaryBox';

afterEach(cleanup);

describe('SummaryBox', () => {
  it('이름과 값을 의미상 짝지어 표시하고 바뀐 값만 갱신한다', () => {
    const rows = [
      { label: '신청 금액', value: '30,000원 (2매)' },
      { label: '입금자명', value: '정우성' },
    ];
    const { rerender } = render(<SummaryBox rows={rows} />);
    expect(screen.getAllByRole('term').map((node) => node.textContent)).toEqual(
      rows.map((row) => row.label),
    );
    expect(screen.getAllByRole('definition').map((node) => node.textContent)).toEqual(
      rows.map((row) => row.value),
    );

    const updated = rows.map((row, index) =>
      index === 0 ? { ...row, value: '15,000원 (1매)' } : row,
    );
    rerender(<SummaryBox rows={updated} />);

    expect(screen.getByText('15,000원 (1매)')).toBeDefined();
    expect(screen.queryByText('30,000원 (2매)')).toBeNull();
    expect(screen.getByText(rows[1].value)).toBeDefined();
  });
});
