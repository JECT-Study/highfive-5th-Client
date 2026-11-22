import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { Chip } from './Chip';

afterEach(cleanup);

describe('Chip', () => {
  it('선택 여부를 aria-pressed로 알리고, 누르면 onClick을 부른다', () => {
    const onClick = vi.fn();
    const { rerender } = render(
      <Chip selected={false} onClick={onClick}>
        1~3년
      </Chip>,
    );

    const chip = screen.getByRole('button', { name: '1~3년' });
    expect(chip.getAttribute('aria-pressed')).toBe('false');
    fireEvent.click(chip);
    expect(onClick).toHaveBeenCalledTimes(1);

    rerender(
      <Chip selected onClick={onClick}>
        1~3년
      </Chip>,
    );
    expect(chip.getAttribute('aria-pressed')).toBe('true');
  });
});
